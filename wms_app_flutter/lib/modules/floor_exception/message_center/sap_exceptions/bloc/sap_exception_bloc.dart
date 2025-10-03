import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/bloc/sap_exception_event.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/bloc/sap_exception_state.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/models/sap_exception.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/services/user_manager.dart';

class SapExceptionBloc extends Bloc<SapExceptionEvent, SapExceptionState> {
  SapExceptionBloc({
    required FloorExceptionService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const SapExceptionState()) {
    final userId = _userManager.userInfo?.userId.toString() ?? '';
    _currentQuery = SapExceptionQuery(userId: userId, roleOrUserId: userId);

    gridBloc = CommonDataGridBloc<SapExceptionRecord>(
      dataLoader: _createLoader(),
    );

    on<SapExceptionSearchSubmitted>(_onSearchSubmitted);
    on<SapExceptionRefreshRequested>(_onRefreshRequested);
    on<SapExceptionClearError>(_onClearError);
  }

  final FloorExceptionService _service;
  final UserManager _userManager;
  late SapExceptionQuery _currentQuery;
  late final CommonDataGridBloc<SapExceptionRecord> gridBloc;

  DataGridLoader<SapExceptionRecord> _createLoader() {
    return (pageIndex) async {
      final requestPage = pageIndex <= 0 ? 1 : pageIndex;
      _currentQuery = _currentQuery.copyWith(pageIndex: requestPage);
      final result = await _service.getSapExceptions(_currentQuery);
      final totalPages = (result.total / _currentQuery.pageSize).ceil();
      return DataGridResponseData(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: result.rows,
      );
    };
  }

  Future<void> _onSearchSubmitted(
    SapExceptionSearchSubmitted event,
    Emitter<SapExceptionState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(
      searchKey: event.keyword,
      pageIndex: 1,
    );
    gridBloc.add(LoadDataEvent<SapExceptionRecord>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    SapExceptionRefreshRequested event,
    Emitter<SapExceptionState> emit,
  ) async {
    gridBloc.add(LoadDataEvent<SapExceptionRecord>(gridBloc.state.currentPage));
  }

  Future<void> _onClearError(
    SapExceptionClearError event,
    Emitter<SapExceptionState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
