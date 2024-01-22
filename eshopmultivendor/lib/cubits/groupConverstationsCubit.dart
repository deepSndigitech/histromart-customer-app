import 'package:eshop_multivendor/Model/groupDetails.dart';
import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GroupConverstationsState {}

class GroupConverstationsInitial extends GroupConverstationsState {}

class GroupConverstationsFetchInProgress extends GroupConverstationsState {}

class GroupConverstationsFetchSuccess extends GroupConverstationsState {
  final List<GroupDetails> groupConverstations;

  GroupConverstationsFetchSuccess({required this.groupConverstations});
}

class GroupConverstationsFetchFailure extends GroupConverstationsState {
  final String errorMessage;

  GroupConverstationsFetchFailure(this.errorMessage);
}

class GroupConverstationsCubit extends Cubit<GroupConverstationsState> {
  final ChatRepository _chatRepository;

  GroupConverstationsCubit(this._chatRepository)
      : super(GroupConverstationsInitial());

  void fetchGroupConverstations({required String userId}) async {
    try {
      emit(GroupConverstationsFetchInProgress());

      emit(GroupConverstationsFetchSuccess(
          groupConverstations:
              await _chatRepository.getGroupConverstationList(userId: userId)));
    } catch (e) {
      emit(GroupConverstationsFetchFailure(e.toString()));
    }
  }

  void markMessagesReadOfGivenGroup({required String? groupId}) {
    if (state is GroupConverstationsFetchSuccess) {
      List<GroupDetails> groupConverstations =
          (state as GroupConverstationsFetchSuccess).groupConverstations;
      final index =
          groupConverstations.indexWhere((group) => group.groupId == groupId);
      if (index != -1) {
        groupConverstations[index] =
            groupConverstations[index].copyWith(isRead: '0');
        emit(GroupConverstationsFetchSuccess(
            groupConverstations: groupConverstations));
      }
    }
  }

  void markNewMessageArrivedInGroup({required String? groupId}) {
    if (state is GroupConverstationsFetchSuccess) {
      List<GroupDetails> groupConverstations =
          (state as GroupConverstationsFetchSuccess).groupConverstations;
      final index =
          groupConverstations.indexWhere((group) => group.groupId == groupId);
      if (index != -1) {
        groupConverstations[index] =
            groupConverstations[index].copyWith(isRead: '1');
        emit(GroupConverstationsFetchSuccess(
            groupConverstations: groupConverstations));
      }
    }
  }
}
