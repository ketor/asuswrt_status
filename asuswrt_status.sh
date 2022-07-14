model=$(nvram get productid)

str_offline="0"

echo $model

case "$model" in
RT-AC5300)
    WLEXE=/jffs/asuswrt_status/wl5300
    cpu_temperature="CPU: $(cat /proc/dmu/temperature | awk '{print $4}' | grep -Eo '[0-9]+') °C"
    ;;
*)
    WLEXE=wl
    cpu_temperature="CPU: $(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1 / 1000}') °C"
    ;;
esac


interface_2g=$(nvram get wl0_ifname)
interface_5g1=$(nvram get wl1_ifname)
interface_5g2=$(nvram get wl2_ifname)
interface_2g_temperature=$($WLEXE -i ${interface_2g} phy_tempsense | awk '{print $1}') 2>/dev/null
interface_5g1_temperature=$($WLEXE -i ${interface_5g1} phy_tempsense | awk '{print $1}') 2>/dev/null
interface_5g2_temperature=$($WLEXE -i ${interface_5g2} phy_tempsense | awk '{print $1}') 2>/dev/null
interface_2g_power=$($WLEXE -i ${interface_2g} txpwr_target_max | awk '{print $NF}') 2>/dev/null
interface_5g1_power=$($WLEXE -i ${interface_5g1} txpwr_target_max | awk '{print $NF}') 2>/dev/null
interface_5g2_power=$($WLEXE -i ${interface_5g2} txpwr_target_max | awk '{print $NF}') 2>/dev/null

[ -n "${interface_2g_temperature}" ] && interface_2g_temperature_c="$(expr ${interface_2g_temperature} / 2 + 20) °C" || interface_2g_temperature_c=${str_offline}" °C"
[ -n "${interface_5g1_temperature}" ] && interface_5g1_temperature_c="$(expr ${interface_5g1_temperature} / 2 + 20) °C" || interface_5g1_temperature_c=${str_offline}" °C"
[ -n "${interface_5g2_temperature}" ] && interface_5g2_temperature_c="$(expr ${interface_5g2_temperature} / 2 + 20) °C" || interface_5g2_temperature_c=${str_offline}" °C"
wl_temperature1="2.4G: ${interface_2g_temperature_c}"
wl_temperature2="5G-1: ${interface_5g1_temperature_c}"
wl_temperature3="5G-2: ${interface_5g2_temperature_c}"

[ -n "${interface_2g_power}" ] && interface_2g_power_d="${interface_2g_power} dBm" || interface_2g_power_d=${str_offline}" dBm"
[ -n "${interface_2g_power}" ] && interface_2g_power_p="$(awk -v x=${interface_2g_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_2g_power_p=${str_offline}" mw"
[ -n "${interface_5g1_power}" ] && interface_5g1_power_d="${interface_5g1_power} dBm" || interface_5g1_power_d=${str_offline}" dBm"
[ -n "${interface_5g1_power}" ] && interface_5g1_power_p="$(awk -v x=${interface_5g1_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_5g1_power_p=${str_offline}" mw"
[ -n "${interface_5g2_power}" ] && interface_5g2_power_d="${interface_5g2_power} dBm" || interface_5g2_power_d=${str_offline}" dBm"
[ -n "${interface_5g2_power}" ] && interface_5g2_power_p="$(awk -v x=${interface_5g2_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_5g2_power_p=${str_offline}" mw"
wl_txpwr1="2.4G: ${interface_2g_power_d} / ${interface_2g_power_p}"
wl_txpwr2="5G-1: ${interface_5g1_power_d} / ${interface_5g1_power_p}"
wl_txpwr3="5G-2: ${interface_5g2_power_d} / ${interface_5g2_power_p}"

echo $cpu_temperature
echo $wl_temperature1
echo $wl_temperature2
echo $wl_temperature3
echo $wl_txpwr1
echo $wl_txpwr2
echo $wl_txpwr3
