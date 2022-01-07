import csv
import argparse
import statistics


def parser():
    parser1 = argparse.ArgumentParser()
    parser1.add_argument('-i', '--inputFile', type = str, metavar = 'input.csv', required = True)
    parser1.add_argument('-o', '--outputFile', type = str, metavar = 'output.csv')
    return parser1.parse_args()


def calcTradeStats(input, output):
    list_of_fill_sizes = [] # aggregations
    active_symbols = {} # top 10 most active stocks
    active_fill_exchanges = {}
    total_bought = 0
    total_bought_notional = 0
    total_sold = 0
    total_sold_notional = 0


    with open(input, 'r') as trades:
        reader = csv.reader(trades, delimiter = ',')
        row_count = 0

        with open(output, 'w') as enriched_trades:
            writer = csv.writer(enriched_trades)

            for row in reader:

                # header
                if row_count == 0:

                    row.extend(['SymbolBought', 'SymbolSold', 'SymbolPosition', 'SymbolNotional',
                                'ExchangeBought', 'ExchangeSold', 'TotalBought', 'TotalSold',
                                'TotalBoughtNotional', 'TotalSoldNotional'])
                    
                    writer.writerow(row)
                    row_count += 1
                    continue

                try:
                    fill_size = int(row[4])
                
                except IndexError:
                    continue

                # SymbolNotional
                # FillSize * FilledPrice
                symbol_notional = round(fill_size * float(row[5]), 2)
                list_of_fill_sizes.append(fill_size)

                symbol = row[1]

                if symbol not in active_symbols:
                    active_symbols[symbol] = [0, 0] # NAMING CONVENTION: [bought, sold]
                
                fill_exchange = row[6]

                if fill_exchange not in active_fill_exchanges:
                    active_fill_exchanges[fill_exchange] = [0, 0] # NAMING CONVENTION: [bought, sold]
                
                # SymbolBought
                # ExchangeBought
                # TotalBought
                # TotalBoughtNotional
                if row[3] == 'b':
                    active_symbols[symbol][0] += fill_size # running total partioned by symbol
                    active_fill_exchanges[fill_exchange][0] += fill_size # running total partitioned by exchange
                    total_bought += fill_size
                    total_bought_notional += symbol_notional
                
                # SymbolSold
                # ExchangeSold
                # TotalSold
                # TotalSoldNotional
                else:
                    active_symbols[symbol][1] += fill_size # running total partioned by symbol
                    active_fill_exchanges[fill_exchange][1] += fill_size # running total partitioned by exchange
                    total_sold += fill_size
                    total_sold_notional += symbol_notional
                
                row.append(active_symbols[symbol][0]) # SymbolBought
                row.append(active_symbols[symbol][1]) # SymbolSold
                row.append(active_symbols[symbol][0] - active_symbols[symbol][1]) # SymbolPosition
                row.append(symbol_notional)
                row.append(active_fill_exchanges[fill_exchange][0]) # ExchangeBought
                row.append(active_fill_exchanges[fill_exchange][1]) # ExchangeSold
                row.append(total_bought)
                row.append(total_sold)
                row.append(total_bought_notional)
                row.append(total_sold_notional)

                writer.writerow(row)
                row_count += 1

    print('Processed Trades: ' + str(row_count - 1) + '\n')

    print('Share Bought: ' + str(total_bought))
    print('Share Bought: ' + str(total_sold))
    print('Total Volume: ' + str(total_bought + total_sold))
    print('Notional Bought: $' + str(round(total_bought_notional, 2)))
    print('Notional Sold: $' + str(round(total_sold_notional, 2)) + '\n')

    for exchange in active_fill_exchanges.keys():
        print(exchange + ' Bought: ' + str(active_fill_exchanges[exchange][0]))
        print(exchange + ' Sold: ' + str(active_fill_exchanges[exchange][1]))

    print('\nAverage Trade Size: ' + str(round(sum(list_of_fill_sizes) / len(list_of_fill_sizes), 2)))
    print('Median Trade Size: ' + str(statistics.median(list_of_fill_sizes)) + '\n')

    symbols = []

    for symbol in active_symbols.keys():
        symbols.append([sum(active_symbols[symbol]), symbol]) # NAMING CONVENTION: [Bought + Sold, Symbol] 

    symbols.sort(reverse = True) # descending order
    ten_or_less = min(10, len(symbols)) # top 10 or lesss

    print(str(ten_or_less) + ' Most Active Symbols:')

    for i in range(ten_or_less):
        print(str(symbols[i][1]) + ' - ' + str(symbols[i][0]))


if __name__ == '__main__':
    args = parser()
    calcTradeStats(args.inputFile, args.outputFile)
    