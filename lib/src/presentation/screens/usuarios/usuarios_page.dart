import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final usuarios = [
    // Usuario(id: 1, nombre: 'Maria', correo: 'test1@gmail.com', online: true),
    // Usuarios(
    //   uid: '2',
    //   nombre: 'Melissa',
    //   email: 'test2@gmail.com',
    //   online: false,
    // ),
    // Usuarios(
    //   uid: '3',
    //   nombre: 'Fernando',
    //   email: 'test3@gmail.com',
    //   online: true,
    // ),
    // Usuarios(uid: '4', nombre: 'Jorge', email: 'test4@gmail.com', online: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios', style: TextStyle(color: Colors.black87)),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            // TODO: logout
          },
          icon: const Icon(Icons.exit_to_app, color: Colors.black87),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _cargarUsuarios,
        header: WaterDropHeader(
          complete: Icon(Icons.check, color: Colors.blue[400]),
          waterDropColor: Colors.blue[400]!,
        ),
        child: _listViewUsuarios(),
      ),
    );
  }

  // ================================
  // Lista de usuarios
  // ================================
  Widget _listViewUsuarios() {
    if (usuarios.isEmpty) {
      return const Center(child: Text('No hay usuarios'));
    }

    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (_, i) => _usuarioListTile(usuarios[i]),
      separatorBuilder: (_, i) => Divider(),
      itemCount: usuarios.length,
    );
  }

  // ================================
  // ITEM
  // ================================
  Widget _usuarioListTile(Usuario user) {
    final persona = user.persona;

    final nombreCompleto = "${persona.nombres} ${persona.apellidos}";

    return ListTile(
      title: Text(nombreCompleto),

      subtitle: Text(user.correo),

      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          persona.nombres.isNotEmpty
              ? persona.nombres.substring(0, 1).toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // CAMBIO: ahora usamos estado en vez de online
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: user.estado ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  // ================================
  // REFRESH
  // ================================
  Future<void> _cargarUsuarios() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      // 🔥 TODO: conectar con tu API real
      // usuarios = response.data;

      setState(() {});
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }
}
