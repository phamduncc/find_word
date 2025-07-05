import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // TODO: Load from SharedPreferences
    _settings = const GameSettings();
    _playerNameController.text = _settings.playerName;
  }

  void _saveSettings() {
    // TODO: Save to SharedPreferences
    Navigator.pop(context);
  }

  void _updateSettings(GameSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF673AB7),
              Color(0xFF3F51B5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Player name section
                      _buildSection(
                        title: 'Player Info',
                        children: [
                          _buildPlayerNameField(),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingL),

                      // Game settings section
                      _buildSection(
                        title: 'Game Settings',
                        children: [
                          _buildDifficultySelector(),
                          const SizedBox(height: AppConstants.spacingM),
                          _buildSwitchTile(
                            title: 'Show Hints',
                            subtitle: 'Display helpful hints during gameplay',
                            value: _settings.showHints,
                            onChanged: (value) {
                              _updateSettings(_settings.copyWith(showHints: value));
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingL),

                      // Audio & Haptics section
                      _buildSection(
                        title: 'Audio & Haptics',
                        children: [
                          _buildSwitchTile(
                            title: 'Sound Effects',
                            subtitle: 'Play sound effects during gameplay',
                            value: _settings.soundEnabled,
                            onChanged: (value) {
                              _updateSettings(_settings.copyWith(soundEnabled: value));
                            },
                          ),
                          _buildSwitchTile(
                            title: 'Vibration',
                            subtitle: 'Vibrate on interactions',
                            value: _settings.vibrationEnabled,
                            onChanged: (value) {
                              _updateSettings(_settings.copyWith(vibrationEnabled: value));
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingL),

                      // About section
                      _buildSection(
                        title: 'About',
                        children: [
                          _buildInfoTile(
                            title: 'Version',
                            subtitle: AppConstants.appVersion,
                            icon: Icons.info,
                          ),
                          _buildInfoTile(
                            title: 'Developer',
                            subtitle: 'Made with ❤️ in Flutter',
                            icon: Icons.code,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Save button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: AppConstants.spacingL),
                  child: GameButton(
                    text: 'SAVE SETTINGS',
                    onPressed: _saveSettings,
                    backgroundColor: Colors.green.shade600,
                    icon: Icons.save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerNameField() {
    return TextField(
      controller: _playerNameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Player Name',
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: 'Enter your name',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.person, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      onChanged: (value) {
        _updateSettings(_settings.copyWith(playerName: value));
      },
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Row(
          children: Difficulty.values.map((difficulty) {
            final isSelected = _settings.difficulty == difficulty;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _updateSettings(_settings.copyWith(difficulty: difficulty));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white30,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        difficulty.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${difficulty.timeLimit}s',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}
