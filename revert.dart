import 'dart:io';

void main() {
  final files = [
    'lib/views/dashboard/dashboard_screen.dart',
    'lib/views/settings/settings_screen.dart',
    'lib/views/profile/profile_screen.dart',
  ];

  for (final file in files) {
    var f = File(file);
    if (!f.existsSync()) continue;
    var c = f.readAsStringSync();

    // Straight replaces
    c = c.replaceAll('AppColors.background(context)', 'AppColors.background');
    c = c.replaceAll('AppColors.surface(context)', 'AppColors.surface');
    c = c.replaceAll('AppColors.textPrimary(context)', 'AppColors.textPrimary');
    c = c.replaceAll(
      'AppColors.textSecondary(context)',
      'AppColors.textSecondary',
    );

    c = c.replaceAll(
      'AppTextStyles.heading1(context)',
      'AppTextStyles.heading1',
    );
    c = c.replaceAll(
      'AppTextStyles.heading2(context)',
      'AppTextStyles.heading2',
    );
    c = c.replaceAll(
      'AppTextStyles.heading3(context)',
      'AppTextStyles.heading3',
    );
    c = c.replaceAll(
      'AppTextStyles.bodyLarge(context)',
      'AppTextStyles.bodyLarge',
    );
    c = c.replaceAll(
      'AppTextStyles.bodyMedium(context)',
      'AppTextStyles.bodyMedium',
    );
    c = c.replaceAll(
      'AppTextStyles.bodySmall(context)',
      'AppTextStyles.bodySmall',
    );
    c = c.replaceAll('AppTextStyles.button(context)', 'AppTextStyles.button');
    c = c.replaceAll('AppTextStyles.caption(context)', 'AppTextStyles.caption');
    c = c.replaceAll('AppTextStyles.label(context)', 'AppTextStyles.label');

    // Formatting handles (Dart formatter puts context on new line)
    c = c.replaceAll(
      'AppTextStyles.bodyMedium(\n      context,\n    )',
      'AppTextStyles.bodyMedium',
    );
    c = c.replaceAll(
      'AppTextStyles.bodySmall(\n      context,\n    )',
      'AppTextStyles.bodySmall',
    );
    c = c.replaceAll(
      'AppTextStyles.heading1(\n      context,\n    )',
      'AppTextStyles.heading1',
    );
    c = c.replaceAll(
      'AppTextStyles.heading2(\n      context,\n    )',
      'AppTextStyles.heading2',
    );
    c = c.replaceAll(
      'AppTextStyles.heading3(\n      context,\n    )',
      'AppTextStyles.heading3',
    );
    c = c.replaceAll(
      'AppColors.textSecondary(\n      context,\n    )',
      'AppColors.textSecondary',
    );
    c = c.replaceAll(
      'AppColors.textPrimary(\n      context,\n    )',
      'AppColors.textPrimary',
    );
    c = c.replaceAll(
      'AppColors.surface(\n      context,\n    )',
      'AppColors.surface',
    );
    c = c.replaceAll(
      'AppColors.background(\n      context,\n    )',
      'AppColors.background',
    );

    c = c.replaceAll(
      'AppTextStyles.bodyMedium(\n                          context,\n                        )',
      'AppTextStyles.bodyMedium',
    );
    c = c.replaceAll(
      'AppTextStyles.bodySmall(\n                          context,\n                        )',
      'AppTextStyles.bodySmall',
    );
    c = c.replaceAll(
      'AppColors.textSecondary(\n                          context,\n                        )',
      'AppColors.textSecondary',
    );

    // specific method signature fixes
    c = c.replaceAll(
      '_buildSettingsItem(\n                      context,\n                      r,',
      '_buildSettingsItem(\n                      r,',
    );
    c = c.replaceAll(
      'Widget _buildSettingsItem(\n    BuildContext context,\n    ResponsiveHelper r,',
      'Widget _buildSettingsItem(\n    ResponsiveHelper r,',
    );

    c = c.replaceAll(
      'Widget _buildProfileCard(BuildContext context, ResponsiveHelper r, dynamic user) {',
      'Widget _buildProfileCard(ResponsiveHelper r, dynamic user) {',
    );
    c = c.replaceAll(
      '_buildProfileCard(context, r, user),',
      '_buildProfileCard(r, user),',
    );
    c = c.replaceAll(
      '_buildStatsRow(\n                context,\n                r,',
      '_buildStatsRow(\n                r,',
    );
    c = c.replaceAll(
      'Widget _buildStatsRow(\n    BuildContext context,\n    ResponsiveHelper r,',
      'Widget _buildStatsRow(\n    ResponsiveHelper r,',
    );
    c = c.replaceAll('_buildMenuSection(context, r),', '_buildMenuSection(r),');
    c = c.replaceAll(
      'Widget _buildMenuSection(BuildContext context, ResponsiveHelper r) {',
      'Widget _buildMenuSection(ResponsiveHelper r) {',
    );
    c = c.replaceAll('_buildAppSection(context, r),', '_buildAppSection(r),');
    c = c.replaceAll(
      'Widget _buildAppSection(BuildContext context, ResponsiveHelper r) {',
      'Widget _buildAppSection(ResponsiveHelper r) {',
    );
    c = c.replaceAll(
      '_buildLogoutButton(context, r),',
      '_buildLogoutButton(r),',
    );
    c = c.replaceAll(
      'Widget _buildLogoutButton(BuildContext context, ResponsiveHelper r) {',
      'Widget _buildLogoutButton(ResponsiveHelper r) {',
    );
    c = c.replaceAll(
      '_buildMenuItem(\n                context,\n                r,',
      '_buildMenuItem(\n                r,',
    );
    c = c.replaceAll(
      'Widget _buildMenuItem(\n    BuildContext context,\n    ResponsiveHelper r,',
      'Widget _buildMenuItem(\n    ResponsiveHelper r,',
    );

    // another format for bodyMedium inside nested columns
    c = c.replaceAll(
      'style: AppTextStyles.bodyMedium(\n                            context,\n                          )',
      'style: AppTextStyles.bodyMedium',
    );
    c = c.replaceAll(
      'style: AppTextStyles.bodySmall(\n                            context,\n                          )',
      'style: AppTextStyles.bodySmall',
    );
    c = c.replaceAll(
      'color: AppColors.textSecondary(context)',
      'color: AppColors.textSecondary',
    );
    c = c.replaceAll(
      'style: AppTextStyles.heading2(context)',
      'style: AppTextStyles.heading2',
    );
    c = c.replaceAll(
      'style: AppTextStyles.heading3(context)',
      'style: AppTextStyles.heading3',
    );
    c = c.replaceAll(
      'style: AppTextStyles.bodyMedium(context)',
      'style: AppTextStyles.bodyMedium',
    );
    c = c.replaceAll(
      'style: AppTextStyles.bodySmall(context)',
      'style: AppTextStyles.bodySmall',
    );

    // extra cleanup for multi-line copyWith
    c = c.replaceAll(')\n                          .copyWith', ').copyWith');
    c = c.replaceAll(')\n                        .copyWith', ').copyWith');

    // Regex global replaces for any remaining nested formats
    c = c.replaceAll(
      RegExp(r'AppTextStyles\.(\w+)\s*\(\s*context\s*,\s*\)'),
      r'AppTextStyles.$1',
    );
    c = c.replaceAll(
      RegExp(r'AppColors\.(\w+)\s*\(\s*context\s*,\s*\)'),
      r'AppColors.$1',
    );
    c = c.replaceAll(
      RegExp(r'AppColors\.(\w+)\s*\(\s*context\s*\)'),
      r'AppColors.$1',
    );
    c = c.replaceAll(
      RegExp(r'AppTextStyles\.(\w+)\s*\(\s*context\s*\)'),
      r'AppTextStyles.$1',
    );

    f.writeAsStringSync(c);
  }
}
