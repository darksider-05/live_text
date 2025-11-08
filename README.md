# Live Text

Live Text is a cross-platform Flutter application that enables real-time text synchronization between a single host and client over a local network. Designed for simplicity, speed, and privacy, it allows seamless text sharing across devices without cloud services, user accounts, or configuration steps. Whether you’re transferring snippets between your phone and laptop or maintaining a synchronized clipboard between devices, Live Text delivers a secure and frictionless experience entirely within your local network.

---

## ⚡ Key Features

* 🔁 **Real-Time Synchronization** — Instantly mirrors text updates between one host and one client in both directions.

* 📱 **Cross-Platform Compatibility** — Works on Android, iOS, and desktop platforms (Windows, macOS, Linux). Web support is not currently implemented.

* 🧩 **Zero-Configuration Setup** — Devices automatically discover each other on the local network; no manual IP entry required.

* 🌐 **Local-Only Communication** — Functions entirely within LAN or mobile hotspot—no internet, cloud, or external servers.

* 📋 **Auto Clipboard** — Optionally, text received from the host is automatically copied to the client’s clipboard for seamless workflow.

* ⚙️ **Lightweight and Efficient** — Minimal CPU, memory, and network usage for continuous background operation.

* 🔒 **Privacy by Design** — No user tracking, accounts, or credentials; all discovery and session data exists only in memory and disappears after the connection ends.

* 🚫 **Single-Client Simplicity** — Maintains a single active connection for predictable and stable behavior. The host disables discovery once connected to prevent additional connections.

* 🔄 **Quick Recovery** — If the host disconnects or fails, the client returns to the lobby; the host list is cleared, allowing fast manual re-scanning (typically within 5 seconds).

---

## ⚙️ Technical Architecture

Live Text employs a hybrid **UDP + WebSocket** communication model to combine fast, low-level discovery with reliable real-time data transfer.

### 🛰️ Discovery Layer — UDP (Port 50987)

The app uses UDP for lightweight device discovery within the local network.  

- **Client-side scan**: Iterates through a /24 subnet of private IP addresses, sending small, stateless “ping” packets at controlled intervals (~40ms apart) to avoid network congestion.  
- **Host response**: Hosts reply with a “pong” containing minimal connection metadata.  
- **Inverse Discovery Method**: This unicast approach avoids Android’s restrictive broadcast permissions and eliminates the need for location access, achieving full discovery capability with zero user configuration.  
- **Ephemeral state**: No IP addresses or network configuration is stored; all discovery data exists only for the duration of the scan or session.  

Once the client identifies the host, the system transitions to the persistent WebSocket channel.

---

### 🔗 Data Channel — WebSocket (Port 50988)

After discovery, the client opens a **WebSocket connection** to the host.  

- All subsequent text synchronization occurs over this reliable channel, ensuring ordered delivery and immediate propagation of clipboard updates.  
- Built using Dart’s `dart:io` sockets and the `web_socket_channel` package for cross-platform support.  
- Hosts immediately **disable UDP discovery** after a successful handshake, preventing new clients from connecting until the session ends.

---

### 🔄 Connection Lifecycle

1. **Discovery Phase**: Client scans the local /24 subnet using UDP pings.  
2. **Handshake**: Host responds with minimal connection metadata.  
3. **Session Establishment**: Client opens a WebSocket connection on port 50988.  
4. **Transition**: Host disables UDP discovery to enforce single-client behavior.  
5. **Runtime Ephemeral State**: All session data exists only in memory. If the connection fails or disconnects, the client returns to the lobby and the host list is cleared. Users can manually re-scan quickly.

---

### 🔒 Security Model

Live Text leverages **security-through-simplicity**:  

- **Local Network Isolation**: All communication occurs within LAN or mobile hotspot; no cloud or external endpoints.  
- **Single-Client Enforcement**: Only one client may connect to a host at any time. Hosts reject additional connection attempts.  
- **Minimal Exposure**: No credentials, accounts, or persistent storage. No background services transmit data outside the device.  
- **Privacy-First Design**: The app avoids exposing IP addresses, network topology, or user configuration. Clipboard and text synchronization are ephemeral, existing only for the session duration.  

By combining ephemeral state, local-only communication, and single-session enforcement, Live Text achieves robust security and privacy without complex encryption layers or identity management.

---

### 🧱 Summary

Live Text delivers a **fast, secure, and private local text-sharing experience** with zero setup, minimal footprint, and user-controlled operations. The architecture prioritizes:

- **Speed** — rapid discovery and real-time text propagation.  
- **Simplicity** — minimal user configuration and ephemeral state.  
- **Privacy** — zero tracking, storage, or permissions beyond local network access.  
- **Predictable behavior** — single-client enforcement and fast recovery ensure a consistent user experience.



#### _log_:

the main part of the backend logic is done. 

the logic of buttons that control clipboard behaviors of the app is done.

the username's logic is added.

the theming system is done, with the saving logic, several bugs were fixed.

premissions are set 

an icon is added for the app

testing is ongoing

and finally, a release will be publised