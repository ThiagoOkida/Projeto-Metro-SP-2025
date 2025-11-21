import '../scripts/populate_database.dart';

/// Serviço para popular o banco de dados
/// Pode ser chamado de dentro do app (ex: botão de desenvolvimento)
class DatabasePopulatorService {
  /// Popula o banco de dados (chama a função do script)
  /// 
  /// Use isso de dentro do app, por exemplo em um botão de desenvolvimento
  static Future<void> populate() async {
    return populateDatabase();
  }
}

