class MqttConfig {
  // Option 1: TCP
  static const String server = 'broker.emqx.io';
  static const int port = 1883;
  
  // Option 2: Websockets (Try this if TCP is blocked)
  static const int wsPort = 8083; 
  static const bool useWebSockets = true; // Switch to true if 1883 fails

  static const String clientIdentifier = 'siwatt_mobile_client';
}
