import React, { useMemo } from "react";
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from "@tanstack/react-table";
import classNames from "classnames";
import { SpotEntry } from "../../hooks/oracle";
import { getCurrency } from "../../../utils/mappings";
import { capitalize, secondsToTime } from "../../../utils/display";

const MINUTES_ALLOWED = 30;
const DECIMALS_TO_SHOW = 10;

interface EntriesTableProps {
  assetKey: string;
  decimals: number;
  oracleResponse: SpotEntry[];
  loading: boolean;
  error: string;
}

const EntriesTable: React.FC<EntriesTableProps> = ({
  assetKey,
  decimals,
  oracleResponse,
  loading,
  error,
}) => {
  const data = useMemo(() => {
    if (error) {
      return [];
    }
    if (loading || !oracleResponse?.length) {
      return [];
    }
    return oracleResponse;
  }, [oracleResponse, loading, error]);

  const { src: currencySrc, alt: currencyAlt } = getCurrency(assetKey);

  const columns = useMemo<ColumnDef<SpotEntry>[]>(
    () => [
      {
        header: "Source",
        accessorFn: (entry) => capitalize(entry.source),
        cell: (info) => (
          <div className="flex items-center">
            <>
              <span
                className={classNames(
                  "mr-2 inline-block h-2 w-2 rounded-full",
                  new Date().valueOf() / 1000 - info.row.original.timestamp >
                    60 * MINUTES_ALLOWED
                    ? "bg-yellow-500"
                    : "bg-green-600"
                )}
              />
              {info.getValue()}
            </>
          </div>
        ),
      },
      {
        header: () => (
          <div className="flex items-center">
            <img
              src={`/assets/currencies/${currencySrc}`}
              alt={currencyAlt}
              className="mr-2 inline h-5 w-5 md:mr-3"
            />
            Value
          </div>
        ),
        accessorKey: "value",
        cell: (info) => (
          <span>
            {(info.row.original.price / 10 ** decimals).toPrecision(
              DECIMALS_TO_SHOW
            )}
          </span>
        ),
      },
      {
        header: "Time",
        accessorFn: (entry) => secondsToTime(entry.timestamp),
      },
    ],
    [decimals, currencyAlt, currencySrc]
  );

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="w-full max-w-7xl overflow-y-hidden overflow-x-scroll rounded-lg shadow-md ring-1 ring-black ring-opacity-5">
      <table className="w-full divide-y divide-slate-300 font-mono">
        <thead className="bg-slate-50">
          {table.getHeaderGroups().map((headerGroup) => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <th key={header.id} colSpan={header.colSpan}>
                  {header.isPlaceholder ? null : (
                    <div
                      className={classNames(
                        "px-3 py-4 text-left text-lg font-semibold text-slate-900"
                      )}
                    >
                      {flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                    </div>
                  )}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody className="bg-white">
          {table.getRowModel().rows.map((row, i) => (
            <tr
              key={row.id}
              className={classNames({
                "bg-slate-50": i % 2,
              })}
            >
              {row.getVisibleCells().map((cell) => (
                <td
                  key={cell.id}
                  className="whitespace-nowrap px-3 py-4 text-slate-900"
                >
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default EntriesTable;
