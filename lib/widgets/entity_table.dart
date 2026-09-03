import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;

  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T>
    extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;

  final int Function(T item) idOf;

  final Set<int> selected;

  final ValueChanged<int>?
      onToggleSelect;

  final String? sortField;
  final bool sortAscending;

  final void Function(String field)?
      onSort;

  final List<Widget> Function(T item)?
      actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    int? sortColumnIndex;

    if (sortField != null) {
      final index = columns.indexWhere(
        (column) =>
            column.sortField ==
            sortField,
      );

      if (index >= 0) {
        sortColumnIndex = index;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,

        columns: [
          ...columns.map((column) {
            return DataColumn(
              label: Text(column.label),
              numeric: column.numeric,

              onSort: column.sortField != null &&
                      onSort != null
                  ? (index, ascending) {
                      onSort!(
                        column.sortField!,
                      );
                    }
                  : null,
            );
          }),

          if (actions != null)
            const DataColumn(
              label: Text('Действия'),
            ),
        ],

        rows: items.map((item) {
          final id = idOf(item);

          return DataRow(
            selected:
                selected.contains(id),

            onSelectChanged:
                onToggleSelect == null
                    ? null
                    : (value) {
                        onToggleSelect!(id);
                      },

            cells: [
              ...columns.map(
                (column) {
                  return DataCell(
                    column.build(item),
                  );
                },
              ),

              if (actions != null)
                DataCell(
                  Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children:
                        actions!(item),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}