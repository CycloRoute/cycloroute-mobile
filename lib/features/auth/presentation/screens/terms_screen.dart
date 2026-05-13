import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Overview',
                'Welcome to CycloRoute. These terms and conditions outline the rules and regulations for the use of our application.',
              ),
              _buildSection(
                context,
                'Use License',
                'Permission is granted to temporarily download one copy of the materials (information or software) on CycloRoute for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBullet('Modifying or copying the materials'),
                    _buildBullet('Using the materials for any commercial purpose or for any public display'),
                    _buildBullet('Attempting to decompile or reverse engineer any software contained on the app'),
                    _buildBullet('Removing any copyright or other proprietary notations from the materials'),
                    _buildBullet('Transferring the materials to another person or "mirroring" the materials on any other server'),
                  ],
                ),
              ),
              _buildSection(
                context,
                'Disclaimer',
                'The materials on CycloRoute are provided on an as-is basis. CycloRoute makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
              ),
              _buildSection(
                context,
                'Limitations',
                'In no event shall CycloRoute or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on CycloRoute, even if CycloRoute or an authorized representative has been notified orally or in writing of the possibility of such damage.',
              ),
              _buildSection(
                context,
                'Accuracy of Materials',
                'The materials appearing on CycloRoute could include technical, typographical, or photographic errors. CycloRoute does not warrant that any of the materials on its application are accurate, complete, or current. CycloRoute may make changes to the materials contained on its application at any time without notice.',
              ),
              _buildSection(
                context,
                'Links',
                'CycloRoute has not reviewed all of the sites linked to its application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by CycloRoute of the site. Use of any such linked website is at the user\'s own risk.',
              ),
              _buildSection(
                context,
                'Modifications',
                'CycloRoute may revise these terms of service for its application at any time without notice. By using this application, you are agreeing to be bound by the then current version of these terms of service.',
              ),
              _buildSection(
                context,
                'Governing Law',
                'These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction in which CycloRoute operates, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Last updated: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'May 12, 2026',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
