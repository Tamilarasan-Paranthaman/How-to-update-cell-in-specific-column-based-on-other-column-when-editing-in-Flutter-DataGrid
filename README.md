# How-to-update-value-in-specific-column-based-on-other-columns-when-updating-value-at-run-time-in-Flutter-DataGrid

The Syncfusion [Flutter DataGrid](https://www.syncfusion.com/flutter-widgets/flutter-datagrid) supports to edit the cell values by setting the [SfDataGrid.allowEditing](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataGrid/allowEditing.html) property as true and [SfDataGrid.navigationMode](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataGrid/navigationMode.html) as cell, [SfDataGrid.selectionMode](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataGrid/selectionMode.html) as other than none.
This article will demonstrate how to update a specific column's value based on other columns when updating values at runtime in the Flutter DataGrid. Specifically, we will update the balance column value when the credit or debit value is changed at runtime.

In this sample, we will update the balance column value when the credit or debit value is changed at runtime.

## Step 1: 
To map data to the SfDataGrid, create a data source class by extending [DataGridSource](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/DataGridSource-class.html). In the [DataGridSource.onCellSubmit](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/DataGridSource/onCellSubmit.html) method, you can update the dependent column value when the corresponding column value changes. After that, call the notifyDataSourceListeners method with the corresponding dependent column RowColumnIndex to notify the dependent column value in the underlying collection has changed, and the DataGrid will refresh that cell accordingly.

In this article, we will demonstrate how to update the balance column value when the credit or debit value is changed at runtime.

```dart
class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(this.employees) {
    dataGridRows =
        employees.map((dataGridRow) => dataGridRow.getDataGridRow()).toList();
  }

  List<Employee> employees = [];
  List<DataGridRow> dataGridRows = [];

  // Helps to hold the new value of all editable widget.
  // Based on the new value we will commit the new value into the corresponding
  // [DataGridCell] on [onSubmitCell] method.
  dynamic newCellValue;

  // Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map((dataGridCell) {
      return Container(
          alignment: (dataGridCell.columnName == 'id' ||
                  dataGridCell.columnName == 'credit' ||
                  dataGridCell.columnName == 'debit' ||
                  dataGridCell.columnName == 'balance')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            dataGridCell.value != null ? dataGridCell.value.toString() : "",
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    if (column.columnName == 'id') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'id', value: newCellValue);
      employees[dataRowIndex].id = newCellValue as int;
    } else if (column.columnName == 'name') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'name', value: newCellValue);
      employees[dataRowIndex].name = newCellValue.toString();
    } else if (column.columnName == 'credit') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'credit', value: newCellValue);
      employees[dataRowIndex].credit = newCellValue as int;

      // Get the value of the 'debit' column for the given dataGridRow,
      int debitValue = dataGridRow
          .getCells()
          .firstWhereOrNull(
              (DataGridCell dataGridCell) => dataGridCell.columnName == 'debit')
          ?.value;

      // Calculate the balance by subtracting debitValue from newCellValue
      int balance = newCellValue - debitValue;

      // Get the index of the 'balance' cell for the given row
      int balanceCellIndex = dataGridRow
          .getCells()
          .indexWhere((element) => element.columnName == 'balance');

      // Update the value of the 'balance' column for the given row
      dataGridRows[dataRowIndex].getCells()[balanceCellIndex] =
          DataGridCell<int>(columnName: 'balance', value: balance);
      employees[dataRowIndex].balance = balance;

      // Call the `notifyDataSourceListeners()` method with the corresponding row and column
      // indices to refresh the cell with the updated value.
      notifyDataSourceListeners(
          rowColumnIndex: RowColumnIndex(rowColumnIndex.rowIndex, balanceCellIndex));
    } else if (column.columnName == 'debit') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'debit', value: newCellValue);
      employees[dataRowIndex].debit = newCellValue as int;

      // Get the value of the 'credit' column for the given dataGridRow,
      int creditValue = dataGridRow
          .getCells()
          .firstWhereOrNull((DataGridCell dataGridCell) =>
              dataGridCell.columnName == 'credit')
          ?.value;
      // Calculate the balance by subtracting the new cell value from the credit value.
      int balance = creditValue - newCellValue as int;

      // Get the index of the 'balance' cell for the given row
      int balanceCellIndex = dataGridRow
          .getCells()
          .indexWhere((element) => element.columnName == 'balance');

      // Update the value of the 'balance' column for the given row
      dataGridRows[dataRowIndex].getCells()[balanceCellIndex] =
          DataGridCell<int>(columnName: 'balance', value: balance);
      employees[dataRowIndex].balance = balance;

      // Call the `notifyDataSourceListeners()` method with the corresponding row and column
      // indices to refresh the cell with the updated value.
      notifyDataSourceListeners(
          rowColumnIndex: RowColumnIndex(rowColumnIndex.rowIndex, balanceCellIndex));
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'balance', value: newCellValue);
      employees[dataRowIndex].balance = newCellValue as int;
    }
  }
}

```

## Step 2: 
Initialize the [SfDataGrid](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataGrid-class.html) widget with all the required properties.

```dart
List<Employee> _employees = [];
  late EmployeeDataSource _employeeDataSource;

  @override
  void initState() {
    super.initState();
    _employees = getEmployeeData();
    _employeeDataSource = EmployeeDataSource(_employees);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syncfusion Flutter DataGrid')),
      body: SfDataGrid(
        source: _employeeDataSource,
        allowEditing: true,
        editingGestureType: EditingGestureType.tap,
        navigationMode: GridNavigationMode.cell,
        selectionMode: SelectionMode.single,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          GridColumn(
              columnName: 'id',
              label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  alignment: Alignment.centerRight,
                  child: const Text('ID'))),
          GridColumn(
              columnName: 'name',
              label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Name'))),
          GridColumn(
              columnName: 'credit',
              label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Credit'))),
          GridColumn(
              columnName: 'debit',
              label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Debit'))),
          GridColumn(
              columnName: 'balance',
              label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Balance'))),
        ],
      ),
    );
  }

```
