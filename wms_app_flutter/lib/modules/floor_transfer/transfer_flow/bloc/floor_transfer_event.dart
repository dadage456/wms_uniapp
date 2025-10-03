import 'package:wms_app/modules/floor_transfer/models/transfer_models.dart';

abstract class FloorTransferEvent {
  const FloorTransferEvent();
}

class FloorTransferInitialized extends FloorTransferEvent {
  const FloorTransferInitialized({this.initialMode});

  final TransferMode? initialMode;
}

class FloorTransferModeChanged extends FloorTransferEvent {
  const FloorTransferModeChanged(this.mode);

  final TransferMode mode;
}

class FloorTransferScanReceived extends FloorTransferEvent {
  const FloorTransferScanReceived(this.code);

  final String code;
}

class FloorTransferQuantitySubmitted extends FloorTransferEvent {
  const FloorTransferQuantitySubmitted(this.quantityText);

  final String quantityText;
}

class FloorTransferStockSelected extends FloorTransferEvent {
  const FloorTransferStockSelected(this.stock);

  final InventoryStock stock;
}

class FloorTransferSelectionChanged extends FloorTransferEvent {
  const FloorTransferSelectionChanged(this.selectedIds);

  final List<String> selectedIds;
}

class FloorTransferDeleteSelected extends FloorTransferEvent {
  const FloorTransferDeleteSelected();
}

class FloorTransferSubmitRequested extends FloorTransferEvent {
  const FloorTransferSubmitRequested();
}

class FloorTransferTabChanged extends FloorTransferEvent {
  const FloorTransferTabChanged(this.index);

  final int index;
}

class FloorTransferInventorySearchRequested extends FloorTransferEvent {
  const FloorTransferInventorySearchRequested({
    required this.keyword,
    required this.step,
    this.page = 1,
  });

  final String keyword;
  final String step;
  final int page;
}

class FloorTransferInventoryPageChanged extends FloorTransferEvent {
  const FloorTransferInventoryPageChanged(this.pageIndex);

  final int pageIndex;
}

class FloorTransferMessageCleared extends FloorTransferEvent {
  const FloorTransferMessageCleared();
}

class FloorTransferResetRequested extends FloorTransferEvent {
  const FloorTransferResetRequested();
}
