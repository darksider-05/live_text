package com.github.darksider_05.livetext.live_text.live_text

import java.net.Inet4Address
import java.net.NetworkInterface
import android.util.Log

object NetworkUtils {
    fun getLocalIPv4(): String {
        val preferredPrefixes = listOf("wlan", "ap", "softap", "eth")
        val excludePrefixes = listOf("lo", "rmnet", "pdp", "ccmni", "tun", "vpn")

        try {
            val interfaces = NetworkInterface.getNetworkInterfaces().toList()

            // Step 1: Preferred interfaces
            for (prefix in preferredPrefixes) {
                for (intf in interfaces) {
                    if (intf.name?.startsWith(prefix) == true) {
                        for (addr in intf.inetAddresses) {
                            if (!addr.isLoopbackAddress && addr is Inet4Address) {
                                val ip = addr.hostAddress
                                if (!ip.startsWith("169.254")) {
                                    Log.d("getLocalIPv4", "Using ${intf.name}: $ip")
                                    return ip
                                }
                            }
                        }
                    }
                }
            }

            // Step 2: Fallback
            for (intf in interfaces) {
                val name = intf.name ?: continue
                if (excludePrefixes.any { name.startsWith(it) }) continue
                for (addr in intf.inetAddresses) {
                    if (!addr.isLoopbackAddress && addr is Inet4Address) {
                        val ip = addr.hostAddress
                        if (!ip.startsWith("169.254")) {
                            Log.d("getLocalIPv4", "Fallback ${intf.name}: $ip")
                            return ip
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return "0.0.0.0"
    }
}
