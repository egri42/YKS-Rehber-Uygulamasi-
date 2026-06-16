import 'package:flutter/material.dart';

/// Tüm TYT/AYT müfredatı — Tek merkezde tutulur.
/// PlanPage, PomodoroPage ve diğer ekranlar bu dosyayı kullanır.
final Map<String, List<String>> mufredat = {
  'Matematik': [
    'Temel Kavramlar',
    'Sayı Basamakları',
    'Fonksiyonlar',
    'Logaritma',
    'Trigonometri',
    'Türev',
    'İntegral',
  ],
  'Geometri': [
    'Doğruda Açılar',
    'Üçgenler',
    'Çokgenler',
    'Çember ve Daire',
    'Analitik Geometri',
  ],
  'Fizik': [
    'Vektörler',
    'Kuvvet ve Hareket',
    'Elektrik',
    'Optik',
    'Modern Fizik',
  ],
  'Türkçe': [
    'Paragraf',
    'Sözcükte Anlam',
    'Cümle Bilgisi',
    'Yazım Kuralları',
  ],
  'Biyoloji': [
    'Hücre',
    'Kalıtım',
    'Sistemler',
    'Bitki Biyolojisi',
  ],
  'Kimya': [
    'Atom ve Yapısı',
    'Periyodik Sistem',
    'Asitler-Bazlar',
    'Organik Kimya',
  ],
  'Tarih': [
    'İslamiyet Öncesi Türk Tarihi',
    'Osmanlı Tarihi',
    'İnkılap Tarihi',
  ],
  'Coğrafya': [
    'Doğa ve İnsan',
    'İklim Bilgisi',
    'Türkiye\'nin Yer Şekilleri',
  ],
};

/// Ders adına göre renk döndürür.
Color dersRengi(String? ders) {
  switch (ders) {
    case 'Matematik':
      return const Color(0xFFEF4444);
    case 'Fizik':
      return const Color(0xFF3B82F6);
    case 'Türkçe':
      return const Color(0xFFF59E0B);
    case 'Biyoloji':
      return const Color(0xFF10B981);
    case 'Kimya':
      return const Color(0xFF06B6D4);
    case 'Geometri':
      return const Color(0xFF8B5CF6);
    case 'Tarih':
      return const Color(0xFFD97706);
    case 'Coğrafya':
      return const Color(0xFF059669);
    default:
      return const Color(0xFF6366F1);
  }
}
