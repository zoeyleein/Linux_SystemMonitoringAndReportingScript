#!/bin/bash
#File name: system_report.sh
#Author: JingYi Li 041091658
#Course: CST8102 341
#Date: Dec 6, 2023
#Description: This program allows user to generate a system report with relevant information.

# to genetate the system report
generate_system_report() {
    echo "Generating system report..."
    sleep 0.5

    # gather system information
    hostname=$(hostname)
    os=$(uname -s)
    kernel=$(uname -r)
    # filter the output of "Model name:", ARM-based systems doesn't show
    # cpu_model=$(lscpu | grep "Model name:")
    # display memory usage statistics in megabytes
    total_memory=$(free -m | awk '/Mem:/ {print $2}')
    free_memory=$(free -m | awk '/Mem:/ {print $4}')
    disk_info=$(df -h / | awk 'NR==2 {print "Total: " $2 ", Used: " $3 ", Free: " $4'})

    # display gathered information
    echo "System Information:"
    echo "Hostname: $hostname"
    echo "Operating System: $os"
    echo "Kernel Version: $kernel"
    echo "CPU Information:"
    echo "Total Memory: ${total_memory}MB"
    echo "Free Memory: ${free_memory}MB"
    echo "Disk Usage Information:"
    echo "$disk_info"

    # log the information to "system_report.log"
    echo "System Information:" >> system_report.log
    echo "Hostname: $hostname" >> system_report.log
    echo "Operating System: $os" >> system_report.log
    echo "Kernel Version: $kernel" >> system_report.log
    echo "CPU Information:" >> system_report.log
    echo "Model name: $cpu_model" >> system_report.log
    echo "Total Memory: ${total_memory}MB" >> system_report.log
    echo "Free Memory: ${free_memory}MB" >> system_report.log
    echo "Disk Usage Information:" >> system_report.log
    echo "$disk_info" >> system_report.log
    echo ""

    # check CPU load
    cpu_load=$(uptime | awk -F'[a-z]:' '{print $2}' | awk -F, '{print $1}' | sed 's/^ *//')
    if (( $(echo "$cpu_load > 0.8" | bc -l) )); then
        echo "WARNING: CPU load is high! ($cpu_load)"
    else
        echo "SUCCESS: CPU load is within acceptable limits ($cpu_load)"
    fi

    # check Memory usage
    memory_percentage=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
    if (( $(echo "$memory_percentage > 50" | bc -l) )); then
        echo "WARNING: Memory usage is high! ($memory_percentage%)"
    else
        echo "SUCCESS: Memory usage is within acceptable limits ($memory_percentage%)"
    fi

    # check Disk usage
    disk_usage_percentage=$(df -h / | awk 'NR==2 {sub(/%/, "", $5); print $5}')
    if (( $(echo "$disk_usage_percentage > 70" | bc -l) )); then
        echo "WARNING: Disk usage is high! ($disk_usage_percentage%)"
    else
        echo "SUCCESS: Disk usage is within acceptable limits ($disk_usage_percentage%)"
    fi
}

# to create an archive
create_archive() {

    # check if the log file exists
    if [ -f system_report.log ]; then
        echo "Archive created successfully."
    else
        echo "Error: Log file does not exist or is empty. Generating a new report before creating the archive."
        
	generate_system_report
    

    # create an archive (e.g., system_report.tar.gz) containing the log file
    tar -czf system_report.tar.gz system_report.log

    # display success message
    echo -e "\nArchive created successfully."
	
    fi
}

# make a main Menu
while true; do
    echo ""
    echo "System Monitoring and Reporting"
    echo "++++++++++++++++++++++++++++"
    echo "1. Generate System Report"
    echo "2. Create Archive"
    echo "3. Exit"
    echo "++++++++++++++++++++++++++++"
    echo -n "Enter your choice: "

    read choice

    case $choice in
        1)
            generate_system_report
            ;;
        2)
            create_archive
            ;;
        3)
            echo "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option! Please choose a valid menu item."
            ;;
    esac
done



