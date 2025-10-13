/// Barrel file para facilitar imports de todas as telas
///
/// Uso:
/// import 'package:app_sanitaria/presentation/screens/screens.dart';
library;

///
/// Em vez de importar cada tela individualmente

// Autenticação
export 'login_screen.dart';
export 'selection_screen.dart';

// Cadastro
export 'professional_registration_screen.dart';
export 'patient_registration_screen.dart';

// Home (duas versões)
export 'home_patient_screen.dart';
export 'home_professional_screen.dart';

// Funcionalidades principais
export 'professionals_list_screen.dart';
export 'professional_profile_detail_screen.dart';
export 'conversations_screen.dart';
export 'individual_chat_screen.dart';
export 'favorites_screen.dart';

// Transações
export 'hiring_screen.dart';
export 'contracts_screen.dart';
export 'contract_detail_screen.dart';

// Avaliações
export 'add_review_screen.dart';

// Conta
export 'profile_screen.dart';
export 'edit_profile_screen.dart';
