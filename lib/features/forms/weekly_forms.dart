import 'text_form_screen.dart';

/// Definición de los campos del Reporte Semanal Individual.
const List<FormFieldConfig> weeklyIndividualFields = [
  FormFieldConfig(key: 'nombre', label: 'Tu nombre'),
  FormFieldConfig(key: 'semana', label: 'Semana #'),
  FormFieldConfig(key: 'proyecto', label: 'Proyecto'),
  FormFieldConfig(
    key: 'meta_1',
    label: 'Meta 1',
    section: 'Avances y Próximos Pasos',
  ),
  FormFieldConfig(key: 'meta_2', label: 'Meta 2'),
  FormFieldConfig(key: 'meta_3', label: 'Meta 3'),
  FormFieldConfig(
    key: 'bloqueos',
    label: '¿Qué te bloquea y qué necesitas del coordinador?',
    hint: 'Si todo está bien, escribe "Sin bloqueos".',
    type: FormFieldType.multiline,
    section: 'Soporte y Asistencia',
  ),
  FormFieldConfig(
    key: 'asistio_reunion',
    label: 'Asististe a la reunión',
    type: FormFieldType.radio,
    options: ['Sí', 'No'],
  ),
];

/// Definición de los campos del Reporte Semanal Coordinador.
const List<FormFieldConfig> weeklyCoordinatorFields = [
  FormFieldConfig(key: 'proyecto', label: 'Proyecto'),
  FormFieldConfig(key: 'nombre', label: 'Nombre'),
  FormFieldConfig(key: 'semana', label: 'Semana #'),
  FormFieldConfig(
    key: 'estado_general',
    label: 'Estado general esta semana',
    type: FormFieldType.radio,
    options: ['En curso', 'Con dificultades', 'Retrasado'],
    section: 'Estado y Avances Técnicos',
  ),
  FormFieldConfig(
    key: 'resumen_avances',
    label: 'Resumen y avances técnicos',
    hint: 'Resume el estado en una frase y describe los avances concretos '
        '(Ej: se completó el modelo CAD del fuselaje).',
    type: FormFieldType.multiline,
  ),
  FormFieldConfig(
    key: 'hitos_responsables',
    label: 'Hitos de la próxima semana y responsables',
    hint: 'Lista los entregables y quién los cumple '
        '(Ej: 1. Definir material para aletas - Juan).',
    type: FormFieldType.multiline,
  ),
  FormFieldConfig(
    key: 'alertas_equipo',
    label: 'Alertas del equipo',
    hint: 'Reporta solo a quienes no entregaron, están retrasados/bloqueados '
        'o necesitan apoyo. Si todo opera con normalidad, escribe '
        '"Todos al día y sin bloqueos".',
    type: FormFieldType.multiline,
    section: 'Novedades del Equipo (Reporte por Excepción)',
  ),
  FormFieldConfig(
    key: 'necesidades',
    label: 'Necesidades y urgencia',
    hint: 'Describe qué necesita el proyecto, el tipo (Recursos / Decisión / '
        'Gestión / Información) y su urgencia (Esta semana / Este mes). '
        'Si no requieres nada, escribe "Sin solicitudes".',
    type: FormFieldType.multiline,
    section: 'Necesidades y Urgencia',
  ),
];
