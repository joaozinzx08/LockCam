
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const PerfilApp());
}

class PerfilApp extends StatelessWidget {
  const PerfilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyProfile',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B15),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
      ),
      home: const TelaPerfil(),
    );
  }
}

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final ImagePicker picker = ImagePicker();

  File? foto;
  String nome = 'Meu Perfil';
  String localizacao = 'Localização não disponível';
  String latitude = '--';
  String longitude = '--';
  String ultimaAtualizacao = '--';

  bool localizacaoObtida = false;
  bool buscandoLocalizacao = false;

  static const roxo = Color(0xFF8B5CF6);
  static const fundoCard = Color(0xFF151827);

  Future<void> escolherFoto(ImageSource origem) async {
    try {
      final imagem = await picker.pickImage(
        source: origem,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (imagem == null || !mounted) return;

      setState(() {
        foto = File(imagem.path);
      });

      mostrarMensagem('Foto atualizada com sucesso!');
    } catch (e) {
      mostrarMensagem('Não foi possível abrir a imagem.');
    }
  }

  void removerFoto() {
    setState(() {
      foto = null;
    });

    mostrarMensagem('Foto removida.');
  }

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFF25283A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void atualizarErroLocalizacao(String mensagem) {
    if (!mounted) return;

    setState(() {
      localizacao = mensagem;
      localizacaoObtida = false;
      buscandoLocalizacao = false;
    });
  }

  Future<void> obterLocalizacao() async {
    if (buscandoLocalizacao) return;

    setState(() {
      buscandoLocalizacao = true;
    });

    try {
      final servicoAtivo =
      await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        atualizarErroLocalizacao(
          'Ative o GPS do dispositivo.',
        );
        return;
      }

      var permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        atualizarErroLocalizacao(
          'Permissão de localização negada.',
        );
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        atualizarErroLocalizacao(
          'Permissão bloqueada. Libere nas configurações.',
        );
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      final agora = DateTime.now();

      setState(() {
        latitude = posicao.latitude.toStringAsFixed(4);
        longitude = posicao.longitude.toStringAsFixed(4);
        localizacao = 'Localização obtida com sucesso';
        localizacaoObtida = true;
        buscandoLocalizacao = false;

        ultimaAtualizacao =
        '${agora.hour.toString().padLeft(2, '0')}:'
            '${agora.minute.toString().padLeft(2, '0')}';
      });

      mostrarMensagem('GPS atualizado!');
    } catch (e) {
      atualizarErroLocalizacao(
        'Não foi possível obter a localização.',
      );
    }
  }

  Widget card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: fundoCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }

  Widget botaoAcao({
    required String texto,
    required IconData icone,
    required VoidCallback? aoClicar,
    bool principal = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: aoClicar,
        icon: Icon(icone, size: 20),
        label: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          principal ? roxo : const Color(0xFF25283A),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF25283A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget informacaoGPS(String titulo, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF202336),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABEÇALHO
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: roxo.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: roxo,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MyProfile',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Seu espaço pessoal',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white54,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // PERFIL
                  card(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: roxo,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor:
                                const Color(0xFF29233F),
                                backgroundImage: foto != null
                                    ? FileImage(foto!)
                                    : null,
                                child: foto == null
                                    ? const Icon(
                                  Icons.person_rounded,
                                  size: 65,
                                  color: roxo,
                                )
                                    : null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: roxo,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: fundoCard,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Personalize sua foto de perfil',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 24),

                        botaoAcao(
                          texto: 'Tirar foto',
                          icone: Icons.camera_alt_rounded,
                          principal: true,
                          aoClicar: () =>
                              escolherFoto(ImageSource.camera),
                        ),

                        const SizedBox(height: 10),

                        botaoAcao(
                          texto: 'Escolher da galeria',
                          icone: Icons.photo_library_rounded,
                          aoClicar: () =>
                              escolherFoto(ImageSource.gallery),
                        ),

                        if (foto != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: removerFoto,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                            ),
                            label: const Text('Remover foto'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                              const Color(0xFFFF7B8A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // TÍTULO LOCALIZAÇÃO
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: roxo,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Minha localização',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // CARD GPS
                  card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: localizacaoObtida
                                    ? Colors.green.withValues(
                                  alpha: 0.12,
                                )
                                    : roxo.withValues(alpha: 0.12),
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: Icon(
                                localizacaoObtida
                                    ? Icons.location_on
                                    : Icons.location_searching,
                                color: localizacaoObtida
                                    ? Colors.greenAccent
                                    : roxo,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status do GPS',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizacao,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: localizacaoObtida
                                          ? Colors.greenAccent
                                          : Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            informacaoGPS(
                              'LATITUDE',
                              latitude,
                            ),
                            const SizedBox(width: 12),
                            informacaoGPS(
                              'LONGITUDE',
                              longitude,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 15,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Última atualização: $ultimaAtualizacao',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        botaoAcao(
                          texto: buscandoLocalizacao
                              ? 'Obtendo localização...'
                              : localizacaoObtida
                              ? 'Atualizar localização'
                              : 'Usar minha localização',
                          icone: localizacaoObtida
                              ? Icons.refresh_rounded
                              : Icons.my_location_rounded,
                          principal: true,
                          aoClicar: buscandoLocalizacao
                              ? null
                              : obterLocalizacao,
                        ),

                        if (buscandoLocalizacao) ...[
                          const SizedBox(height: 14),
                          const Center(
                            child: CircularProgressIndicator(
                              color: roxo,
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AVISO DE PRIVACIDADE
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: roxo.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: roxo.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: roxo,
                          size: 25,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sua privacidade importa. A localização é solicitada apenas quando você autoriza.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Center(
                    child: Text(
                      'MyProfile • Flutter App',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
