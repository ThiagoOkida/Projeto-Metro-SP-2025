import 'package:cloud_firestore/cloud_firestore.dart';

/// Estatísticas do Dashboard
class DashboardStats {
  final int totalMateriais;
  final int totalInstrumentos;
  final int instrumentosAtivos;
  final int alertasAtivos;
  final int materiaisCriticos;

  DashboardStats({
    required this.totalMateriais,
    required this.totalInstrumentos,
    required this.instrumentosAtivos,
    required this.alertasAtivos,
    required this.materiaisCriticos,
  });
}

/// Repositório para estatísticas do Dashboard
class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca estatísticas do dashboard
  Future<DashboardStats> getStats() async {
    // Busca contagens em paralelo
    final results = await Future.wait([
      _firestore.collection('materiais').count().get(),
      _firestore.collection('instrumentos').count().get(),
      _firestore
          .collection('instrumentos')
          .where('status', whereIn: ['disponivel', 'emprestado'])
          .count()
          .get(),
      _firestore
          .collection('alertas')
          .where('resolvido', isEqualTo: false)
          .count()
          .get(),
      _firestore
          .collection('materiais')
          .where('quantidade', isLessThan: 10)
          .count()
          .get(),
    ]);

    return DashboardStats(
      totalMateriais: results[0].count ?? 0,
      totalInstrumentos: results[1].count ?? 0,
      instrumentosAtivos: results[2].count ?? 0,
      alertasAtivos: results[3].count ?? 0,
      materiaisCriticos: results[4].count ?? 0,
    );
  }

  /// Stream de estatísticas (atualiza em tempo real)
  Stream<DashboardStats> getStatsStream() {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getStats());
  }
}

