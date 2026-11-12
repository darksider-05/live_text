package com.github.darksider_05.livetext.live_text.live_text

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.util.Log
import java.net.Inet4Address
import java.net.NetworkInterface

object NetworkUtils {

    private const val TAG = "getLocalIPv4"

    // NET_CAPABILITY_LOCAL_NETWORK was added in Android 15 / API 35.
    // Its documented value is 38.
    //
    // We keep the numeric value here instead of referencing the constant
    // directly so this source can still compile with older compileSdk levels.
    private const val NET_CAPABILITY_LOCAL_NETWORK = 38

    fun getLocalIPv4(context: Context): String {
        // First try Android's ConnectivityManager APIs.
        // This is the preferred/modern path.
        try {
            val ip = getFromConnectivityManager(context)

            if (ip != null) {
                Log.d(TAG, "Using ConnectivityManager address: $ip")
                return ip
            }
        } catch (e: Exception) {
            Log.e(TAG, "ConnectivityManager lookup failed", e)
        }

        // If Android did not give us a suitable network/address,
        // fall back to the old NetworkInterface scan.
        try {
            val ip = getFromNetworkInterfaces()

            if (ip != null) {
                Log.d(TAG, "Using NetworkInterface fallback address: $ip")
                return ip
            }
        } catch (e: Exception) {
            Log.e(TAG, "NetworkInterface fallback failed", e)
        }

        return "0.0.0.0"
    }

    /**
     * Modern Android network lookup.
     *
     * Priority:
     *
     * 1. LOCAL_NETWORK
     *    Android 15+ hotspot/tethering/local-network case.
     *
     * 2. Wi-Fi
     *    Normal case where the phone is connected to another Wi-Fi host.
     *
     * 3. Ethernet
     *    Kept as a secondary useful local-network possibility.
     *
     * VPN/cellular/etc. are deliberately not selected here because
     * they are not the local Wi-Fi address this app is looking for.
     */
    private fun getFromConnectivityManager(context: Context): String? {
        val connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE)
                    as? ConnectivityManager
                    ?: return null

        val activeNetwork = connectivityManager.activeNetwork
        val networks = connectivityManager.allNetworks

        if (networks.isEmpty()) {
            return null
        }

        data class Candidate(
            val score: Int,
            val network: Network,
            val interfaceName: String?,
            val ip: String
        )

        val candidates = mutableListOf<Candidate>()

        for (network in networks) {
            val capabilities = try {
                connectivityManager.getNetworkCapabilities(network)
            } catch (_: Exception) {
                null
            } ?: continue

            val linkProperties = try {
                connectivityManager.getLinkProperties(network)
            } catch (_: Exception) {
                null
            } ?: continue

            val interfaceName = linkProperties.interfaceName

            val isWifi = capabilities.hasTransport(
                NetworkCapabilities.TRANSPORT_WIFI
            )

            val isEthernet = capabilities.hasTransport(
                NetworkCapabilities.TRANSPORT_ETHERNET
            )

            val isVpn = capabilities.hasTransport(
                NetworkCapabilities.TRANSPORT_VPN
            )

            // A VPN address is not the physical/local Wi-Fi address we want.
            if (isVpn) {
                continue
            }

            val isLocalNetwork =
                Build.VERSION.SDK_INT >= 35 &&
                capabilities.hasCapability(NET_CAPABILITY_LOCAL_NETWORK)

            // Only consider networks that make sense for this particular
            // job. This prevents a mobile-data address from winning.
            if (!isLocalNetwork && !isWifi && !isEthernet) {
                continue
            }

            val ipv4 = findUsableIPv4(linkProperties) ?: continue

            var score = 0

            // Highest priority:
            // Android 15+ explicitly identifies hotspot/tethering/local
            // networks using NET_CAPABILITY_LOCAL_NETWORK.
            if (isLocalNetwork) {
                score += 10000
            }

            // Normal Wi-Fi client connection.
            if (isWifi) {
                score += 5000
            }

            // Ethernet is useful, but less relevant to the stated use case.
            if (isEthernet) {
                score += 1000
            }

            // Give the active network a small bonus, but don't let a
            // cellular/VPN network outrank the local Wi-Fi network.
            if (network == activeNetwork) {
                score += 500
            }

            candidates.add(
                Candidate(
                    score = score,
                    network = network,
                    interfaceName = interfaceName,
                    ip = ipv4
                )
            )

            Log.d(
                TAG,
                "Candidate: network=$network " +
                    "interface=$interfaceName " +
                    "ip=$ipv4 " +
                    "wifi=$isWifi " +
                    "ethernet=$isEthernet " +
                    "localNetwork=$isLocalNetwork " +
                    "score=$score"
            )
        }

        if (candidates.isEmpty()) {
            return null
        }

        val best = candidates.maxByOrNull { it.score } ?: return null

        Log.d(
            TAG,
            "Selected network: " +
                "interface=${best.interfaceName}, " +
                "ip=${best.ip}, " +
                "score=${best.score}"
        )

        return best.ip
    }

    /**
     * Extract the first usable IPv4 address from a network's LinkProperties.
     */
    private fun findUsableIPv4(linkProperties: LinkProperties): String? {
        for (linkAddress in linkProperties.linkAddresses) {
            val address = linkAddress.address

            if (address !is Inet4Address) {
                continue
            }

            if (address.isLoopbackAddress) {
                continue
            }

            if (address.isLinkLocalAddress) {
                continue
            }

            val ip = address.hostAddress ?: continue

            if (ip == "0.0.0.0") {
                continue
            }

            return ip
        }

        return null
    }

    /**
     * Original interface-based approach, retained as a fallback.
     *
     * This is intentionally very similar to your original implementation,
     * because it is useful on devices/OEM Android versions where the
     * ConnectivityManager information doesn't expose the hotspot network
     * in the way we expect.
     */
    private fun getFromNetworkInterfaces(): String? {
        val preferredPrefixes = listOf(
            "wlan",
            "ap",
            "softap",
            "eth"
        )

        val excludePrefixes = listOf(
            "lo",
            "rmnet",
            "pdp",
            "ccmni",
            "tun",
            "vpn"
        )

        val interfaces = NetworkInterface.getNetworkInterfaces()?.toList()
            ?: return null

        // First: explicitly preferred interfaces.
        for (prefix in preferredPrefixes) {
            for (intf in interfaces) {
                val name = intf.name ?: continue

                if (!name.startsWith(prefix, ignoreCase = true)) {
                    continue
                }

                for (addr in intf.inetAddresses) {
                    if (addr.isLoopbackAddress) {
                        continue
                    }

                    if (addr !is Inet4Address) {
                        continue
                    }

                    if (addr.isLinkLocalAddress) {
                        continue
                    }

                    val ip = addr.hostAddress ?: continue

                    if (ip == "0.0.0.0") {
                        continue
                    }

                    Log.d(
                        TAG,
                        "Fallback preferred interface: $name -> $ip"
                    )

                    return ip
                }
            }
        }

        // Second: broader fallback.
        for (intf in interfaces) {
            val name = intf.name ?: continue

            if (excludePrefixes.any {
                    name.startsWith(it, ignoreCase = true)
                }) {
                continue
            }

            for (addr in intf.inetAddresses) {
                if (addr.isLoopbackAddress) {
                    continue
                }

                if (addr !is Inet4Address) {
                    continue
                }

                if (addr.isLinkLocalAddress) {
                    continue
                }

                val ip = addr.hostAddress ?: continue

                if (ip == "0.0.0.0") {
                    continue
                }

                Log.d(
                    TAG,
                    "Fallback interface: $name -> $ip"
                )

                return ip
            }
        }

        return null
    }
}