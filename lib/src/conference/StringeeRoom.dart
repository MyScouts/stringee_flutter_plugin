import 'dart:async';

import '../../stringee_flutter_plugin.dart';

class StringeeRoom {
  late String _id;
  late bool _recored;
  late StringeeClient _client;
  StreamController<dynamic> _eventStreamController = StreamController();
  late StreamSubscription<dynamic> _subscriber;

  String get id => _id;

  bool get recored => _recored;

  StreamController<dynamic> get eventStreamController => _eventStreamController;

  StringeeRoom(StringeeClient client, Map<dynamic, dynamic> info) {
    this._client = client;
    this._id = info['id'];
    this._recored = info['recored'];
    _subscriber = client.eventStreamController.stream.listen(this._listener);
  }

  void _listener(dynamic event) {
    assert(event != null);
    final Map<dynamic, dynamic> map = event;
    if (map['nativeEventType'] == StringeeObjectEventType.room.index &&
        map['uuid'] == _client.uuid) {
      switch (map['event']) {
        case 'didJoinRoom':
          handleDidJoinRoom(map['body']);
          break;
        case 'didLeaveRoom':
          handleDidLeaveRoom(map['body']);
          break;
        case 'didAddVideoTrack':
          handleDidAddVideoTrack(map['body']);
          break;
        case 'didRemoveVideoTrack':
          handleDidRemoveVideoTrack(map['body']);
          break;
        case 'didReceiveRoomMessage':
          handleDidReceiveRoomMessage(map['body']);
          break;
        case 'didReceiveVideoTrackControlNotification':
          handleDidReceiveVideoTrackControlNotification(map['body']);
          break;
      }
    }
  }

  void handleDidJoinRoom(Map<dynamic, dynamic> map) {
    String? roomId = map['roomId'];
    if (roomId != this._id) return;

    _eventStreamController.add(
        {"eventType": StringeeRoomEvents.didJoinRoom, "body": map['body']});
  }

  void handleDidLeaveRoom(Map<dynamic, dynamic> map) {
    String? roomId = map['roomId'];
    if (roomId != this._id) return;

    _eventStreamController.add(
        {"eventType": StringeeRoomEvents.didLeaveRoom, "body": map['body']});
  }

  void handleDidAddVideoTrack(Map<dynamic, dynamic> map) {
    String? roomId = map['roomId'];
    if (roomId != this._id) return;

    _eventStreamController.add({
      "eventType": StringeeRoomEvents.didAddVideoTrack,
      "body": map['body']
    });
  }

  void handleDidRemoveVideoTrack(Map<dynamic, dynamic> map) {
    String? roomId = map['roomId'];
    if (roomId != this._id) return;

    _eventStreamController.add({
      "eventType": StringeeRoomEvents.didRemoveVideoTrack,
      "body": map['body']
    });
  }

  void handleDidReceiveRoomMessage(Map<dynamic, dynamic> map) {
    String? roomId = map['roomId'];
    if (roomId != this._id) return;

    _eventStreamController.add({
      "eventType": StringeeRoomEvents.didReceiveRoomMessage,
      "body": map['body']
    });
  }

  void handleDidReceiveVideoTrackControlNotification(
      Map<dynamic, dynamic> map) {
    String? roomId = map['roomId'];
    if (roomId != this._id) return;

    _eventStreamController.add({
      "eventType": StringeeRoomEvents.didReceiveVideoTrackControlNotification,
      "body": map['body']
    });
  }

  /// Publish local [StringeeVideoTrack]
  Future<Map<dynamic, dynamic>> publish(StringeeVideoTrack videoTrack) async {
    final params = {
      'isLocal': videoTrack.isLocal,
      'screem': videoTrack.isScreenCapture,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('room.publish', params);
  }

  /// Un publish local [StringeeVideoTrack]
  Future<Map<dynamic, dynamic>> unPublish(StringeeVideoTrack videoTrack) async {
    final params = {
      'isLocal': videoTrack.isLocal,
      'screem': videoTrack.isScreenCapture,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('room.unPublish', params);
  }

  /// Subscribe [StringeeVideoTrack]
  Future<Map<dynamic, dynamic>> subscribe(
      StringeeVideoTrack videoTrack, StringeeVideoTrackOptions options) async {
    final params = {
      'trackId': videoTrack.id,
      'options': options.toJson(),
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('room.subscribe', params);
  }

  /// Un subscribe [StringeeVideoTrack]
  Future<Map<dynamic, dynamic>> unsubscribe(
      StringeeVideoTrack videoTrack) async {
    final params = {
      'trackId': videoTrack.id,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('room.unsubscribe', params);
  }

  /// Leave [StringeeRoom]
  Future<Map<dynamic, dynamic>> leave(bool allClient) async {
    final params = {
      'allClient': allClient,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('room.leave', params);
  }

  /// Send a message to [StringeeRoom]
  Future<Map<dynamic, dynamic>> sendMessage(Map<dynamic, dynamic> msg) async {
    final params = {
      'msg': msg,
      'uuid': _client.uuid,
    };
    return await StringeeClient.methodChannel
        .invokeMethod('room.sendMessage', params);
  }
}
