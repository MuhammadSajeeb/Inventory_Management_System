#!/bin/bash

items_file="items.txt"
customers_file="customers.txt"
stock_report="stock_report.txt"

touch "$items_file" "$customers_file" "$stock_report"

add_item() {
    echo "Enter item ID:"
    read id
    echo "Enter item name:"
    read name
    echo "Enter item price:"
    read price
    echo "Enter item quantity:"
    read quantity

    echo "$id:$name:$price:$quantity" >> "$items_file"
    echo "Item $name with ID $id added to the inventory."
}

display_stock() {
    echo "Stock Details:"
    echo "ID | Name | Price | Quantity"
    echo "----------------------------"
    awk -F ":" '{printf "%-3s | %-10s | %-6s | %-8s\n", $1, $2, $3, $4}' "$items_file"
}

sell_item() {
    echo "Enter customer name:"
    read customer_name

    display_stock

    echo "Enter item ID to sell:"
    read sell_id

    stock_quantity=$(awk -F ":" -v id="$sell_id" '$1 == id {print $4}' "$items_file")
    if [ -z "$stock_quantity" ]; then
        echo "Item ID $sell_id not found."
    elif [ "$stock_quantity" -eq 0 ]; then
        echo "Item ID $sell_id is out of stock."
    else
        echo "Enter quantity to sell:"
        read sell_quantity

        if [ "$sell_quantity" -gt "$stock_quantity" ]; then
            echo "Not enough stock available for sale."
        else
            item_name=$(awk -F ":" -v id="$sell_id" '$1 == id {print $2}' "$items_file")
            item_price=$(awk -F ":" -v id="$sell_id" '$1 == id {print $3}' "$items_file")

            total_amount=$((sell_quantity * item_price))

            awk -v id="$sell_id" -v sq="$sell_quantity" 'BEGIN {FS=OFS=":"} $1 == id {$4 -= sq} 1' "$items_file" > temp && mv temp "$items_file"

            echo "Sold $sell_quantity unit(s) of $item_name to $customer_name for a total of $total_amount."
        fi
    fi
}

remove_item() {
    echo "Enter item ID to remove:"
    read remove_id

    # Remove item by ID from the inventory file
    awk -v id="$remove_id" -F ":" '$1 != id' "$items_file" > temp && mv temp "$items_file"
    echo "Item with ID $remove_id removed from the inventory."
}

update_stock_report() {
    echo "Generating Stock Report..."
    echo "Stock Report as of $(date)" > "$stock_report"
    echo "ID | Name | Price | Quantity" >> "$stock_report"
    echo "----------------------------" >> "$stock_report"
    cat "$items_file" | awk -F ":" '{printf "%-3s | %-10s | %-6s | %-8s\n", $1, $2, $3, $4}' >> "$stock_report"
    echo "Stock Report has been updated. Check $stock_report."
}

while true; do
    echo "
    Inventory Management System
    ---------------------------
    1. Add Item
    2. Display Stock
    3. Sell Item
    4. Remove Item
    5. Generate Stock Report
    6. Exit
    ---------------------------
    Enter your choice:"
    read choice

    case $choice in
        1) add_item;;
        2) display_stock;;
        3) sell_item;;
        4) remove_item;;
        5) update_stock_report;;
        6) echo "Exiting..."; exit;;
        *) echo "Invalid choice. Please enter a valid option.";;
    esac
done
