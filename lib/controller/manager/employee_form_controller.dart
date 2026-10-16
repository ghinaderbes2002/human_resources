// employee_form_controller.dart
// متحكم نموذج إضافة/تعديل موظف (بنفس قواعد التحقق في الويب)
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/employee_manager_controller.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/manager/employee_manager_service.dart';
import 'package:human_resources/model/manager/employee_models.dart';
import 'package:human_resources/view/widget/manager/manager_widgets.dart';

class EmployeeFormController extends GetxController {
  /// الموظف المراد تعديله (null = إضافة)
  final ManagedEmployee? editing;
  EmployeeFormController({this.editing});

  bool get isEdit => editing != null;
  EmployeeManagerController get list => EmployeeManagerController.to;

  final formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------- الحقول
  final fullName = TextEditingController();
  final fingerprint = TextEditingController();
  final nationalId = TextEditingController();
  final idNumber = TextEditingController();
  final phone1 = TextEditingController();
  final phone2 = TextEditingController();
  final phone3 = TextEditingController();
  final residence = TextEditingController();
  final salary = TextEditingController();
  final allowances = TextEditingController();
  final advance = TextEditingController();
  final insurance = TextEditingController();
  final overtime = TextEditingController(text: '1.5');
  final daily = TextEditingController();
  final hourly = TextEditingController();
  final birthPlace = TextEditingController();
  final agreement = TextEditingController();
  final notes = TextEditingController();

  List<TextEditingController> get _allTextControllers => [
        fullName, fingerprint, nationalId, idNumber, phone1, phone2, phone3,
        residence, salary, allowances, advance, insurance, overtime, daily,
        hourly, birthPlace, agreement, notes,
      ];

  String? birthDate;
  String? joiningDate;
  String? insuranceStart;
  String? insuranceEnd;

  String employeeType = 'permanent';
  int? positionId;
  int? professionId;
  String? workSystem;
  int? shiftId;

  // -------------------------------------------------------- القوائم المساعدة
  Staterequest lookupsStatus = Staterequest.none;
  String? lookupsError;
  List<JobTitleItem> jobTitles = [];
  List<ProfessionItem> professions = [];
  List<ShiftItem> shifts = [];
  String? shiftsError;
  bool shiftsLoading = false;

  List<String> workSystemOptions = [];
  bool systemsLoading = false;
  String? systemsError;

  // ----------------------------------------------------------------- الملفات
  String? photoPath;
  String? certificatePath;
  String? certificateName;

  /// مكونات راتب مبدئية (إضافة فقط)
  final List<SalaryComponentDraft> drafts = [];

  bool submitting = false;

  bool _dailyAuto = true;
  bool _hourlyAuto = true;

  bool get isPermanent => employeeType == 'permanent';
  bool get isTemporary => employeeType == 'temporary';
  bool get hasInsurance => (_num(insurance) ?? 0) > 0;

  @override
  void onInit() {
    super.onInit();
    final e = editing;
    if (e != null) _prefill(e);
    loadLookups();
  }

  @override
  void onClose() {
    for (final c in _allTextControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void _prefill(ManagedEmployee e) {
    fullName.text = e.fullName == '-' ? '' : e.fullName;
    fingerprint.text = e.fingerprintId ?? '';
    nationalId.text = e.nationalId ?? '';
    phone1.text = e.mobile1 ?? '';
    residence.text = e.residence ?? '';
    salary.text = _fmt(e.salary);
    allowances.text = _fmt(e.allowances);
    // الخادم يُرجع 0 عند عدم التحديد، والتحقق يتطلب 1-100 عند الإدخال
    advance.text = (e.advancePercentage ?? 0) > 0 ? _fmt(e.advancePercentage) : '';
    overtime.text = _fmt(e.overtimeMultiplier ?? 1.5);
    daily.text = _fmt(e.dailyRate);
    hourly.text = _fmt(e.hourlyRate);
    birthPlace.text = e.placeOfBirth ?? '';
    birthDate = e.dateOfBirth == null ? null : MFormat.dateOnly(e.dateOfBirth);
    employeeType = e.employeeType ?? 'permanent';
    workSystem = e.workSystem;
    shiftId = e.shiftId;
    _dailyAuto = daily.text.isEmpty;
    _hourlyAuto = hourly.text.isEmpty;
  }

  // ------------------------------------------------------------- التحميل

  Future<void> loadLookups() async {
    lookupsStatus = Staterequest.loading;
    lookupsError = null;
    update();

    final results = await Future.wait([
      list.jobTitles(),
      list.professions(),
    ]);
    final jt = results[0] as ListResult<JobTitleItem>;
    final pr = results[1] as ListResult<ProfessionItem>;

    if (!jt.ok || (!isEdit && !pr.ok)) {
      lookupsStatus = Staterequest.failure;
      lookupsError = jt.error ?? pr.error;
      update();
      return;
    }
    jobTitles = jt.items;
    professions = pr.items;

    // في التعديل: ربط اسم المسمى الوظيفي بمعرّفه
    final e = editing;
    if (e != null && e.position != null) {
      for (final t in jobTitles) {
        if (t.name.trim() == e.position!.trim()) {
          positionId = t.id;
          break;
        }
      }
    }

    lookupsStatus = Staterequest.success;
    update();

    await loadWorkSystems(keepCurrent: isEdit);
    if (workSystem == 'shift' || isEdit) await loadShifts();
  }

  Future<void> loadShifts() async {
    if (shifts.isNotEmpty || shiftsLoading) return;
    shiftsLoading = true;
    shiftsError = null;
    update();
    final r = await list.shifts();
    shiftsLoading = false;
    if (r.ok) {
      shifts = r.items;
      shiftsError = null;
    } else {
      shiftsError = r.error;
    }
    update();
  }

  Future<void> loadWorkSystems({bool keepCurrent = false}) async {
    systemsError = null;
    if (isTemporary) {
      systemsLoading = false;
      workSystemOptions = List.of(EmployeeLabels.temporarySystems);
    } else if (positionId == null) {
      systemsLoading = false;
      workSystemOptions = [];
    } else {
      systemsLoading = true;
      update();
      final requested = positionId;
      final r = await EmployeeManagerService.fetchEnabledSystems(requested!);
      // تجاهل النتيجة إذا تغيّر المسمى أثناء التحميل
      if (requested != positionId) return;
      systemsLoading = false;
      if (r.ok) {
        workSystemOptions = r.items;
        if (workSystemOptions.isEmpty) {
          systemsError = 'لا توجد أنظمة عمل مفعّلة لهذا المسمى الوظيفي';
        }
      } else {
        workSystemOptions = List.of(EmployeeLabels.permanentSystems);
        systemsError = r.error;
      }
    }
    final ws = workSystem;
    if (ws != null && !workSystemOptions.contains(ws)) {
      if (keepCurrent) {
        workSystemOptions = [...workSystemOptions, ws];
      } else {
        workSystem = null;
        shiftId = null;
      }
    }
    update();
  }

  // ------------------------------------------------------------ التغييرات

  void setEmployeeType(String type) {
    if (type == employeeType) return;
    employeeType = type;
    positionId = null;
    professionId = null;
    workSystem = null;
    shiftId = null;
    update();
    loadWorkSystems();
  }

  void setPosition(int? id) {
    if (id == positionId) return;
    positionId = id;
    workSystem = null;
    shiftId = null;
    update();
    loadWorkSystems();
  }

  void setProfession(int? id) {
    professionId = id;
    update();
  }

  void setWorkSystem(String? v) {
    workSystem = v;
    if (v != 'shift') shiftId = null;
    update();
    if (v == 'shift') loadShifts();
  }

  void setShift(int? id) {
    shiftId = id;
    update();
  }

  void setDate(String field, DateTime? d) {
    final v = d == null ? null : MFormat.date(d);
    switch (field) {
      case 'birth':
        birthDate = v;
        break;
      case 'joining':
        joiningDate = v;
        break;
      case 'insurance_start':
        insuranceStart = v;
        break;
      case 'insurance_end':
        insuranceEnd = v;
        break;
    }
    update();
  }

  /// تعبئة سعر اليوم والساعة تلقائياً من الراتب (إن كانا فارغين أو محسوبين تلقائياً)
  void onSalaryChanged(String v) {
    final s = double.tryParse(v.trim());
    if (s == null || s <= 0) return;
    if (_dailyAuto || daily.text.trim().isEmpty) {
      daily.text = _fmt(_round2(s / 30));
      _dailyAuto = true;
    }
    final d = double.tryParse(daily.text.trim());
    if (d != null && d > 0 && (_hourlyAuto || hourly.text.trim().isEmpty)) {
      hourly.text = _fmt(_round2(d / 8));
      _hourlyAuto = true;
    }
  }

  void onDailyChanged(String v) {
    _dailyAuto = v.trim().isEmpty;
    final d = double.tryParse(v.trim());
    if (d != null && d > 0 && (_hourlyAuto || hourly.text.trim().isEmpty)) {
      hourly.text = _fmt(_round2(d / 8));
      _hourlyAuto = true;
    }
  }

  void onHourlyChanged(String v) {
    _hourlyAuto = v.trim().isEmpty;
  }

  /// لإظهار/إخفاء تواريخ التأمين
  void onInsuranceChanged(String _) => update();

  // ---------------------------------------------------------------- الملفات

  Future<void> pickPhoto() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    final ext = (f.extension ?? '').toLowerCase();
    if (f.path == null || !['png', 'jpg', 'jpeg'].contains(ext)) {
      MDialogs.error('يُسمح بصور بصيغة PNG أو JPG فقط');
      return;
    }
    if (f.size > EmployeeManagerService.maxAttachmentBytes) {
      MDialogs.error('حجم الصورة يتجاوز الحد المسموح (16 ميجابايت)');
      return;
    }
    photoPath = f.path;
    update();
  }

  void removePhoto() {
    photoPath = null;
    update();
  }

  static const certificateExtensions = [
    'pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx', 'xlsx', 'xls',
  ];

  Future<void> pickCertificate() async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: certificateExtensions,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    final ext = (f.extension ?? '').toLowerCase();
    if (f.path == null || !certificateExtensions.contains(ext)) {
      MDialogs.error('نوع الملف غير مسموح');
      return;
    }
    if (f.size > EmployeeManagerService.maxAttachmentBytes) {
      MDialogs.error('حجم الملف يتجاوز الحد المسموح (16 ميجابايت)');
      return;
    }
    certificatePath = f.path;
    certificateName = f.name;
    update();
  }

  void removeCertificate() {
    certificatePath = null;
    certificateName = null;
    update();
  }

  // ------------------------------------------------------- مكونات الراتب

  void saveDraft(SalaryComponentDraft d, {int? index}) {
    if (index != null && index >= 0 && index < drafts.length) {
      drafts[index] = d;
    } else {
      drafts.add(d);
    }
    update();
  }

  void removeDraft(SalaryComponentDraft d) {
    drafts.remove(d);
    update();
  }

  // ---------------------------------------------------------------- التحقق

  String? validateFullName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'الاسم الكامل مطلوب';
    if (s.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    return null;
  }

  String? validateRequired(String? v, String label) =>
      (v ?? '').trim().isEmpty ? '$label مطلوب' : null;

  String? validateNumber(String? v, {double? min, double? max, bool required = false}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return required ? 'هذا الحقل مطلوب' : null;
    final n = double.tryParse(s);
    if (n == null) return 'قيمة رقمية غير صالحة';
    if (min != null && n < min) return 'القيمة يجب ألا تقل عن ${_fmt(min)}';
    if (max != null && n > max) return 'القيمة يجب ألا تزيد عن ${_fmt(max)}';
    return null;
  }

  String? validatePosition(int? v) {
    if (!isPermanent) return null;
    if (isEdit && jobTitles.isEmpty) return null;
    return v == null ? 'المسمى الوظيفي مطلوب' : null;
  }

  String? validateProfession(int? v) {
    if (!isTemporary || isEdit) return null;
    return v == null ? 'المهنة مطلوبة' : null;
  }

  String? validateWorkSystem(String? v) => v == null ? 'نظام العمل مطلوب' : null;

  String? validateShift(int? v) =>
      workSystem == 'shift' && v == null ? 'الوردية مطلوبة' : null;

  String? validateInsuranceStart() {
    if (isEdit || !isPermanent || !hasInsurance) return null;
    return insuranceStart == null ? 'تاريخ بداية التأمينات مطلوب' : null;
  }

  String? validateInsuranceEnd() {
    if (isEdit || !isPermanent || !hasInsurance) return null;
    if (insuranceEnd == null) return 'تاريخ نهاية التأمينات مطلوب';
    final s = insuranceStart;
    if (s != null && s.compareTo(insuranceEnd!) > 0) {
      return 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية';
    }
    return null;
  }

  // ------------------------------------------------------------------ الحفظ

  /// يُرجع true عند نجاح الحفظ (لتُغلق الصفحة)
  Future<bool> submit() async {
    if (submitting) return false;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) {
      MDialogs.error('يرجى تصحيح الحقول المطلوبة');
      return false;
    }
    submitting = true;
    update();
    final ok = isEdit ? await _submitEdit() : await _submitCreate();
    submitting = false;
    update();
    return ok;
  }

  Future<bool> _submitCreate() async {
    final fields = <String, dynamic>{
      'full_name': fullName.text.trim(),
      'employee_type': employeeType,
      'work_system': workSystem,
      if (isPermanent) 'position': positionId,
      if (isTemporary) 'profession': professionId,
      if (workSystem == 'shift' && shiftId != null) 'shift_id': shiftId,
      'fingerprint_id': _text(fingerprint),
      'national_id': _text(nationalId),
      'id_number': _text(idNumber),
      'phone1': _text(phone1),
      'phone2': _text(phone2),
      'phone3': _text(phone3),
      'residence': _text(residence),
    };
    if (isPermanent) {
      final ins = _num(insurance) ?? 0;
      fields.addAll({
        'salary': _num(salary) ?? 0,
        'allowances': _num(allowances) ?? 0,
        'advancePercentage': _num(advance),
        'insurance_deduction': ins,
        if (ins > 0) 'insurance_start_date': insuranceStart,
        if (ins > 0) 'insurance_end_date': insuranceEnd,
        'overtime_multiplier': _num(overtime) ?? 1.5,
        'daily_rate': _num(daily),
        'hourly_rate': _num(hourly),
        'birth_date': birthDate,
        'birth_place': _text(birthPlace),
        'date_of_joining': joiningDate,
        'agreement': _text(agreement),
        'notes': _text(notes),
      });
    }

    final r = await EmployeeManagerService.createEmployee(
      fields,
      photoPath: photoPath,
      certificatePath: certificatePath,
    );
    if (!r.ok) {
      MDialogs.error(r.messageOr('تعذر إضافة الموظف'));
      return false;
    }

    // حفظ مكونات الراتب المبدئية (لا يحفظها الخادم ضمن طلب الإنشاء)
    final newId = mToInt(employeeMapOf(employeeMapOf(r.data)['employee'])['id']);
    var failed = 0;
    if (newId != null && isPermanent) {
      for (final d in drafts) {
        final cr = await EmployeeManagerService.createSalaryComponent(newId, d.toJson());
        if (!cr.ok) failed++;
      }
    } else if (isPermanent) {
      failed = drafts.length;
    }

    await list.load(silent: true);
    if (failed > 0) {
      MDialogs.error('تمت إضافة الموظف لكن تعذر حفظ $failed من الإضافات/الخصومات');
    } else {
      MDialogs.success('تمت إضافة الموظف بنجاح');
    }
    return true;
  }

  Future<bool> _submitEdit() async {
    final e = editing!;
    final body = <String, dynamic>{
      'fingerprint_id': _text(fingerprint),
      'full_name': fullName.text.trim(),
      'employee_type': employeeType,
      'mobile_1': _text(phone1),
      'national_id': _text(nationalId),
      'residence': _text(residence),
      'work_system': workSystem,
      if (isPermanent && positionId != null) 'position': positionId,
      if (workSystem == 'shift') 'shift': shiftId,
    };
    if (isPermanent) {
      body.addAll({
        'salary': _num(salary) ?? 0,
        'allowances': _num(allowances) ?? 0,
        'advancePercentage': _num(advance) ?? 0,
        'overtime_multiplier': _num(overtime) ?? 1.5,
        'daily_rate': _num(daily),
        'hourly_rate': _num(hourly),
        'date_of_birth': birthDate,
        'place_of_birth': _text(birthPlace),
      });
    }
    final r = await EmployeeManagerService.updateEmployee(e.id, body);
    if (!r.ok) {
      MDialogs.error(r.messageOr('تعذر تعديل بيانات الموظف'));
      return false;
    }
    await list.load(silent: true);
    MDialogs.success('تم تعديل بيانات الموظف بنجاح');
    return true;
  }

  // ---------------------------------------------------------------- أدوات

  static String? _text(TextEditingController c) {
    final s = c.text.trim();
    return s.isEmpty ? null : s;
  }

  static double? _num(TextEditingController c) => double.tryParse(c.text.trim());

  static double _round2(double v) => (v * 100).roundToDouble() / 100;

  static String _fmt(num? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }
}
