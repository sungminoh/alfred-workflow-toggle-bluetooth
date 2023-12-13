query={query}

IFS=_ read -r action address <<< "$query"

if [ "$action" == "Connect" ]; then
    blueutil --connect "$address"
elif [ "$action" == "Disconnect" ]; then
    blueutil --disconnect "$address"
else
    echo "Invalid action. Please use 'connect' or 'disconnect'."
fi
