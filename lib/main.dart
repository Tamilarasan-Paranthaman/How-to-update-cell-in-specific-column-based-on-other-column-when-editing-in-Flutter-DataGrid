import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MaterialApp(home: SfDataGridDemo()));
}

class SfDataGridDemo extends StatefulWidget {
  const SfDataGridDemo({Key? key}) : super(key: key);

  @override
  SfDataGridDemoState createState() => SfDataGridDemoState();
}

class SfDataGridDemoState extends State {
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

  List<Employee> getEmployeeData() {
    return [
      Employee(10001, 'Jack', 90000, 40000, 50000),
      Employee(10002, 'Lara', 73000, 33000, 40000),
      Employee(10003, 'Linda', 49000, 10000, 39000),
      Employee(10004, 'Stark', 44000, 7000, 37000),
      Employee(10005, 'Ellis', 40000, 6500, 34500),
      Employee(10006, 'Owens', 40000, 6000, 34000),
      Employee(10007, 'James', 36000, 5000, 31000),
      Employee(10008, 'Steve', 34000, 4500, 28500),
      Employee(10009, 'Perry', 29000, 4000, 25000),
      Employee(10010, 'Stark', 26000, 2000, 24000),
    ];
  }
}

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

  /// Help to control the editable text in [TextField] widget.
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
      //indices to refresh the cell with the updated value.
      notifyDataSourceListeners(
          rowColumnIndex:
              RowColumnIndex(rowColumnIndex.rowIndex, balanceCellIndex));
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
          rowColumnIndex:
              RowColumnIndex(rowColumnIndex.rowIndex, balanceCellIndex));
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'balance', value: newCellValue);
      employees[dataRowIndex].balance = newCellValue as int;
    }
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;

    final bool isNumericType = column.columnName == 'id' ||
        column.columnName == 'credit' ||
        column.columnName == 'debit' ||
        column.columnName == 'balance';

    // Holds regular expression pattern based on the column type.
    final RegExp regExp = _getRegExp(isNumericType, column.columnName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        style: const TextStyle(fontSize: 14),
        controller: editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        autofocus: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(regExp)
        ],
        keyboardType: isNumericType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = int.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          // Call [CellSubmit] callback to fire the canSubmitCell and
          // onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  RegExp _getRegExp(bool isNumericKeyBoard, String columnName) {
    return isNumericKeyBoard ? RegExp('[0-9]') : RegExp('[a-zA-Z ]');
  }
}

class Employee {
  Employee(this.id, this.name, this.credit, this.debit, this.balance);

  int? id;
  String? name;
  int? credit;
  int? debit;
  int? balance;

  DataGridRow getDataGridRow() {
    return DataGridRow(cells: [
      DataGridCell(columnName: 'id', value: id),
      DataGridCell(columnName: 'name', value: name),
      DataGridCell(columnName: 'credit', value: credit),
      DataGridCell(columnName: 'debit', value: debit),
      DataGridCell(columnName: 'balance', value: balance),
    ]);
  }
}
