import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/empty_patrullaje.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/home_quick_actions.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/home_stats_section.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/location_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/main_patrullaje_button.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/patrullaje_header.dart';

import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';

class HomeContent extends StatelessWidget {
  final HomeState homeState;
  final TrackingState trackingState;

  const HomeContent({
    super.key,
    required this.homeState,
    required this.trackingState,
  });

  @override
  Widget build(BuildContext context) {
    final patrullaje = homeState.patrullaje;

    final isEmpty =
        homeState.status == PatrullajeStatus.sinAsignacion ||
        patrullaje == null;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(LoadPatrullajeActivo());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isEmpty) ...[
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.30,
                  child: const Center(child: EmptyPatrullaje()),
                ),
              ] else ...[
                PatrullajeHeader(homeState: homeState),
                const SizedBox(height: 20),

                MainPatrullajeButton(homeState: homeState),
                const SizedBox(height: 20),

                LocationCard(trackingState: trackingState),
                const SizedBox(height: 20),
              ],

              const HomeStatsSection(),

              const SizedBox(height: 28),

              Text(
                'Información para el patrullaje',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              HomeQuickActions(
                patrullajeId: patrullaje?.id,
                patrullajeActivo: homeState.status == PatrullajeStatus.enCurso,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
