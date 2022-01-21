import 'wechat_file.dart';

const String _source = "source";
const String _appPkg = "appPkg";
const String _appName = "appName";
const String _appId = "appId";
const String _agentId = "agentId";
const String _schema = 'schema';

mixin WeChatShareBaseModel {
  Map toMap();
}

class WeChatShareTextModel implements WeChatShareBaseModel {
  final String source;
  final String? appPkg;
  final String? appName;
  final String? appId; //企业唯一标识。创建企业后显示在，我的企业 CorpID字段
  final String? agentId; //应用唯一标识。显示在具体应用下的 AgentId字段

  WeChatShareTextModel({
    required this.source,
    this.appPkg,
    this.appName,
    this.appId,
    this.agentId,
  });

  @override
  Map toMap() {
    return {
      _source: source,
      _appPkg: appPkg,
      _appName: appName,
      _appId: appId,
      _agentId: agentId,
    };
  }
}

class WeChatShareImageModel implements WeChatShareBaseModel {
  final String fileName;
  final String filePath;
  final String? appPkg;
  final String? appName;
  final String? appId; //企业唯一标识。创建企业后显示在，我的企业 CorpID字段
  final String? agentId; //应用唯一标识。显示在具体应用下的 AgentId字段

  WeChatShareImageModel({
    required this.fileName,
    required this.filePath,
    this.appPkg,
    this.appName,
    this.appId,
    this.agentId,
  });

  @override
  Map toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      _appPkg: appPkg,
      _appName: appName,
      _appId: appId,
      _agentId: agentId,
    };
  }
}

class WeChatShareFileModel implements WeChatShareBaseModel {
  final String fileName;
  final String filePath;
  final String? appPkg;
  final String? appName;
  final String? appId; //企业唯一标识。创建企业后显示在，我的企业 CorpID字段
  final String? agentId; //应用唯一标识。显示在具体应用下的 AgentId字段

  WeChatShareFileModel({
    required this.fileName,
    required this.filePath,
    this.appPkg,
    this.appName,
    this.appId,
    this.agentId,
  });

  @override
  Map toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      _appPkg: appPkg,
      _appName: appName,
      _appId: appId,
      _agentId: agentId,
    };
  }
}

class WeChatShareVideoModel implements WeChatShareBaseModel {
  final String fileName;
  final String filePath;
  final String? appPkg;
  final String? appName;
  final String? appId; //企业唯一标识。创建企业后显示在，我的企业 CorpID字段
  final String? agentId; //应用唯一标识。显示在具体应用下的 AgentId字段

  WeChatShareVideoModel({
    required this.fileName,
    required this.filePath,
    this.appPkg,
    this.appName,
    this.appId,
    this.agentId,
  });

  @override
  Map toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      _appPkg: appPkg,
      _appName: appName,
      _appId: appId,
      _agentId: agentId,
    };
  }
}

class WeChatShareWebPageModel implements WeChatShareBaseModel {
  final String webpageUrl;
  final String? thumbUrl;
  final String? title;
  final String? description;
  final String? appPkg;
  final String? appName;
  final String? appId; //企业唯一标识。创建企业后显示在，我的企业 CorpID字段
  final String? agentId; //应用唯一标识。显示在具体应用下的 AgentId字段

  WeChatShareWebPageModel({
    required this.webpageUrl,
    this.thumbUrl,
    this.title,
    this.description,
    this.appPkg,
    this.appName,
    this.appId,
    this.agentId,
  });

  @override
  Map toMap() {
    return {
      'webpageUrl': webpageUrl,
      'thumbUrl': thumbUrl,
      'title': thumbUrl,
      'description': description,
      _appPkg: appPkg,
      _appName: appName,
      _appId: appId,
      _agentId: agentId,
    };
  }
}

class WeChatShareMiniProgramModel implements WeChatShareBaseModel {
  final String username;
  final String path;
  final String title;
  final String? description;
  final WeChatImage? hdImageData;

  final String? appPkg;
  final String? appName;
  final String? appId; //企业唯一标识。创建企业后显示在，我的企业 CorpID字段
  final String? agentId; //应用唯一标识。显示在具体应用下的 AgentId字段
  final String? schema;

  WeChatShareMiniProgramModel({
    required this.username,
    required this.path,
    required this.title,
    this.description,
    this.hdImageData,
    this.appPkg,
    this.appName,
    this.appId,
    this.agentId,
    this.schema,
  });

  @override
  Map toMap() {
    return {
      'username': username,
      'path': path,
      'title': title,
      'description': description,
      'hdImageData': hdImageData,
      _appPkg: appPkg,
      _appName: appName,
      _appId: appId,
      _agentId: agentId,
      _schema: schema,
    };
  }
}
