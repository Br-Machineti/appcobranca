library aplicativo_cpl.globals;

import 'package:droid_foto/classes/Usuario.dart';
import 'package:camera/camera.dart';

Usuario usuarioLogado =
    Usuario(id: 0, cnpj: '', cpf: '', logged: 0, nome: '', senha: '');

late CameraDescription camera;

Map<String, String> systemBaseConfigs = {
  'api_url': 'https://brmachinepag.com.br/gerenciadornovo/api/indexapi.php?a=getdadosalocacao&m=cobranca_imagem',
  'basicAuth': 'Basic SEU_BASE64_AQUI'
};
