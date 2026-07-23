import 'package:ali_auth/ali_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePageWeb extends StatefulWidget {
  const MyHomePageWeb({super.key});

  @override
  State<StatefulWidget> createState() => MyHomePageWebState();
}

class MyHomePageWebState extends State<MyHomePageWeb> {
  String _sdkVersion = '获取中...';
  String _status = '就绪';
  String accessToken = '';
  String jwtToken = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSdkVersion();
  }

  Future<void> _loadSdkVersion() async {
    try {
      final version = await AliAuth.sdkVersion;
      setState(() => _sdkVersion = version ?? '未知');
    } catch (e) {
      setState(() => _sdkVersion = '获取失败');
    }
  }

  Future<void> _startAuth() async {
    if (accessToken.isEmpty || jwtToken.isEmpty) {
      setState(() => _status = '请先填写 accessToken 和 jwtToken');
      return;
    }
    setState(() {
      _isLoading = true;
      _status = '鉴权中...';
    });
    try {
      await AliAuth.checkAuthAvailable(accessToken, jwtToken,
          success: (status) {
        if (kDebugMode) debugPrint('checkAuthAvailable success: $status');
        setState(() {
          _status = '鉴权成功: $status';
          _isLoading = false;
        });
        // 鉴权成功后获取 Token
        AliAuth.getVerifyToken(
            success: (token) {
              if (kDebugMode) debugPrint('getVerifyToken success: $token');
              setState(() {
                _status = '获取Token成功: $token';
                _isLoading = false;
              });
            },
            error: (err) {
              if (kDebugMode) debugPrint('getVerifyToken error: $err');
              setState(() {
                _status = '获取Token失败: $err';
                _isLoading = false;
              });
            });
      }, error: (status) {
        if (kDebugMode) debugPrint('checkAuthAvailable error: $status');
        setState(() {
          _status = '鉴权失败: $status';
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _status = '异常: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AliAuth 一键登录演示'),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // 状态栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // 功能列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // SDK 版本信息
                  _buildSectionTitle('ℹ️ 基本信息'),
                  _buildCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.sd_card, size: 18, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Text('SDK 版本: ', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                          Text(_sdkVersion, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.language, size: 18, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Text('平台: Web', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // 号码校验
                  _buildSectionTitle('🔐 本机号码校验'),
                  _buildCard([
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Web 端仅支持本机号码校验功能，不支持一键登录。请先通过服务端获取 accessToken 和 jwtToken。',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'accessToken',
                          hintText: '请输入从服务端获取的 accessToken',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (v) => accessToken = v,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'jwtToken',
                          hintText: '请输入从服务端获取的 jwtToken',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (v) => jwtToken = v,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _startAuth,
                          icon: _isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.verified_user, size: 18),
                          label: Text(_isLoading ? '处理中...' : '开始鉴权'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            foregroundColor: Colors.blue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ]),
                  const SizedBox(height: 16),
                  // 说明
                  _buildSectionTitle('📋 功能说明'),
                  _buildCard([
                    _buildInfoItem(Icons.phone_android, '一键登录', '仅支持 Android/iOS 原生平台'),
                    _buildInfoItem(Icons.web, '号码校验', '支持 Web 端，通过 accessToken + jwtToken 鉴权'),
                    _buildInfoItem(Icons.sim_card, '获取运营商', '仅支持 Android/iOS，Web 端无 SIM 卡信息'),
                    _buildInfoItem(Icons.settings, '动态参数配置', '仅支持 Android/iOS 原生平台'),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade400),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}