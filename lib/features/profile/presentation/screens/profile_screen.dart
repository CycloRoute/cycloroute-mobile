import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';

import 'package:provider/provider.dart';

import 'package:cyclerisk/app/routes.dart';

import 'package:cyclerisk/core/providers/auth_provider.dart';

import 'package:cyclerisk/core/theme/app_colors.dart';

import 'package:cyclerisk/features/auth/data/models/localization_extensions.dart';

import 'package:cyclerisk/l10n/app_localizations.dart';



class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});



  @override

  Widget build(BuildContext context) {

    final l10n = appL10n(context);



    return Scaffold(

      appBar: AppBar(

        title: Text(l10n.profile),

        backgroundColor: AppColors.background,

        surfaceTintColor: Colors.transparent,

      ),

      body: Consumer<AuthProvider>(

        builder: (context, auth, _) {

          final user = auth.currentUser;



          if (user == null) {

            return Center(child: Text(l10n.noProfileLoaded));

          }



          return ListView(

            padding: const EdgeInsets.all(20),

            children: [

              CircleAvatar(

                radius: 36,

                backgroundColor: AppColors.primary.withOpacity(0.12),

                child: Text(

                  auth.firstName.isNotEmpty

                      ? auth.firstName[0].toUpperCase()

                      : '?',

                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                    color: AppColors.primary,

                    fontWeight: FontWeight.w800,

                  ),

                ),

              ),

              const SizedBox(height: 16),

              Text(

                user.name,

                style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                  fontWeight: FontWeight.w800,

                ),

              ),

              const SizedBox(height: 20),

              _InfoTile(label: l10n.emailLabel, value: user.emailAddress),

              if (user.phoneNumber?.isNotEmpty == true)

                _InfoTile(label: l10n.phoneLabel, value: user.phoneNumber!),

              _InfoTile(label: l10n.roleLabel, value: user.role.label(l10n)),

              _InfoTile(

                label: l10n.defaultRouteLabel,

                value: user.defaultRoutePreference.label(l10n),

              ),

              const SizedBox(height: 24),

              OutlinedButton(

                onPressed: () =>

                    Navigator.of(context).pushNamed(AppRoutes.settings),

                child: Text(l10n.editRoutePreference),

              ),

            ],

          );

        },

      ),

    );

  }

}



class _InfoTile extends StatelessWidget {

  const _InfoTile({required this.label, required this.value});



  final String label;

  final String value;



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 14),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: Theme.of(context).textTheme.labelMedium?.copyWith(

              color: AppColors.textSecondary,

            ),

          ),

          const SizedBox(height: 4),

          Text(

            value,

            style: Theme.of(context).textTheme.titleMedium?.copyWith(

              fontWeight: FontWeight.w600,

            ),

          ),

        ],

      ),

    );

  }

}

