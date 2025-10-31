# Project Overview

Live Text is a cross-platform Flutter application that enables real-time text synchronization between a single host and client over a local network. Designed for simplicity, speed, and privacy, it allows seamless text sharing across devices without cloud services, user accounts, or configuration steps.
Whether you’re transferring snippets between your phone and laptop or maintaining a synchronized clipboard between devices, Live Text delivers a secure and frictionless experience through local-only communication.

## ⚡ Key Features

* 🔁 Real-Time Synchronization — Instantly mirrors text updates between one host and one client in both directions.

* 📱 Cross-Platform Compatibility — Works across Android, iOS, and desktop platforms using Flutter’s unified runtime.

* 🧩 Zero-Configuration Setup — Devices automatically discover each other on the local network; no manual IP entry required.

* 🌐 Local-Only Communication — Functions entirely within your LAN or hotspot—no internet, cloud, or external servers.

* ⚙️ Lightweight and Efficient — Minimal CPU, memory, and network usage for continuous background operation.

* 🔒 Privacy by Design — No user tracking, accounts, or credentials—just secure, direct peer-to-peer communication.

* 🚫 Single-Client Simplicity — Maintains a single active connection for predictable and stable behavior.


## ⚙️ Technical Architecture

The app employs a hybrid UDP + WebSocket communication model to combine fast, low-level discovery with reliable real-time data transfer.

### 🛰️ Discovery Layer — UDP (Port 50987)

The app uses UDP to perform lightweight device discovery within the local network.

A client-side IP range scan is executed, iterating through common private network subnets (e.g., 192.168.x.1–254) to locate the host.

Each probe sends a small, stateless “ping” packet, to which the host responds with a “pong” containing its connection metadata.

This Inverse Discovery Method avoids Android’s restrictive broadcast permissions and eliminates the need for location access—achieving full discovery capability with zero user configuration.

Once the client successfully identifies the host, the system transitions to a persistent connection channel.

### 🔗 Data Channel — WebSocket (Port 50988)

Following successful discovery, the client opens a WebSocket connection to the host.

All subsequent text synchronization occurs over this reliable channel, ensuring ordered delivery and immediate propagation of clipboard updates.

Both sides maintain a minimal protocol layer built on Dart’s dart:io sockets and the web_socket_channel package for cross-platform compatibility.

### 🔄 Connection Lifecycle

Discovery Phase: Client scans local IP range using UDP pings.

Handshake: Host replies with connection metadata.

Session Establishment: Client initiates a WebSocket connection on port 50988.

Transition: Upon successful WebSocket handshake, the host immediately disables UDP discovery, ensuring no new clients can connect.

This architecture combines the speed of UDP discovery with the reliability of WebSocket data transfer while maintaining strict control over the connection lifecycle.

### 🔒 Security Model

The app’s security-through-simplicity approach is centered on isolation, minimal exposure, and local-only operation.

### 🧱 Network Boundary Security

The application operates exclusively within local networks (LAN or mobile hotspot).

By design, no external or cloud-based endpoints are involved—communication never leaves the user’s local environment.

The LAN/hotspot boundary effectively serves as the primary security perimeter, preventing external intrusion.

👥 Single-Client Enforcement

Only one client may connect to a host at any time.

Once a WebSocket connection is established, the host:

Stops responding to UDP discovery pings.

Rejects any additional WebSocket connection attempts.

This behavior prevents session hijacking, eliminates data races, and maintains deterministic synchronization.

### 🧩 Simplicity as Security

No user credentials, cloud sync, or external APIs.

No runtime permissions beyond local network access.

No background services transmitting data outside the device.

By leveraging architectural simplicity, Live Text achieves robust security without the complexity of encryption layers, tokens, or identity management—relying instead on local network isolation and strict single-session enforcement.



#### _log_:

the main part of the backend logic is done. 

the logic of buttons that control clipboard behaviors of the app is done.

the required username's logic is added.

the theming system is done, with the saving logic, several bugs were fixed.

next, will set up premissions 

then add an icon for the app

then there is testing

and finally, a release will be publised