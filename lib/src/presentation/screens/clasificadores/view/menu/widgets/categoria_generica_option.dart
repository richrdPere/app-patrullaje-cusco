// categoria_generica_option.dart

import 'package:flutter/material.dart';

class CategoriaGenericaOption {
  final int id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final IconData icon;
  final Color color;

  const CategoriaGenericaOption({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.icon,
    required this.color,
  });
}

const categoriasGenericasClasificador = <CategoriaGenericaOption>[
  CategoriaGenericaOption(
    id: 1,
    codigo: '01',
    nombre: 'Presuntas actividades delictivas',
    descripcion:
        'Alertas tempranas en apoyo a la Policía Nacional por hechos presuntamente delictivos.',
    icon: Icons.gavel_outlined,
    color: Color(0xFFC62828),
  ),
  CategoriaGenericaOption(
    id: 2,
    codigo: '02',
    nombre: 'Presuntas faltas',
    descripcion:
        'Hechos contra la persona, el patrimonio, la seguridad y la tranquilidad pública.',
    icon: Icons.report_problem_outlined,
    color: Color(0xFFEF6C00),
  ),
  CategoriaGenericaOption(
    id: 3,
    codigo: '03',
    nombre: 'Presuntas infracciones',
    descripcion:
        'Tránsito, transporte, bienestar animal, ordenanzas y licencias municipales.',
    icon: Icons.traffic_outlined,
    color: Color(0xFFF9A825),
  ),
  CategoriaGenericaOption(
    id: 4,
    codigo: '04',
    nombre: 'Ayuda y apoyo',
    descripcion:
        'Ayuda, auxilio, rescate y apoyo a personas, áreas municipales y otras entidades.',
    icon: Icons.volunteer_activism_outlined,
    color: Color(0xFF2E7D32),
  ),
  CategoriaGenericaOption(
    id: 5,
    codigo: '05',
    nombre: 'Desastres y espacios afectados',
    descripcion:
        'Desastres, servicios esenciales, infraestructura y espacios públicos en riesgo.',
    icon: Icons.flood_outlined,
    color: Color(0xFF0277BD),
  ),
  CategoriaGenericaOption(
    id: 6,
    codigo: '06',
    nombre: 'Acontecimientos especiales',
    descripcion:
        'Suicidios, intentos, muertes repentinas y otros acontecimientos especiales.',
    icon: Icons.emergency_outlined,
    color: Color(0xFF6A1B9A),
  ),
  CategoriaGenericaOption(
    id: 7,
    codigo: '07',
    nombre: 'Operativos',
    descripcion:
        'Operativos municipales, estrategias preventivas y operativos especiales.',
    icon: Icons.security_outlined,
    color: Color(0xFF455A64),
  ),
];
