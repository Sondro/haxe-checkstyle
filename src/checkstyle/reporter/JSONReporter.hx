package checkstyle.reporter;

import checkstyle.reporter.BaseReporter;
import haxe.Json;
import checkstyle.LintMessage.SeverityLevel;

class JSONReporter extends BaseReporter {

	var jsonReport:GlobalReport;
	var fileReport:FileReport;

	override public function start() {
		jsonReport = [];
		super.start();
	}

	override public function fileStart(f:LintFile) {
		fileReport = {
			fileName: f.name,
			messages: []
		};
		jsonReport.push(fileReport);
	}

	override public function finish() {
		if (file != null) report.add(Json.stringify(jsonReport));
		super.finish();
	}

	override public function addMessage(m:LintMessage) {
		var reportMessage:ReportMessage = {
			line: m.line,
			column: m.startColumn,
			severity: BaseReporter.severityString(m.severity),
			message: m.message
		};
		fileReport.messages.push(reportMessage);

		switch (m.severity) {
			case ERROR: errors++;
			case WARNING: warnings++;
			case INFO: infos++;
			default:
		}

		Sys.print(applyColour(getMessage(m).toString(), m.severity));
	}
}

typedef ReportMessage = {
	var line:Int;
	var column:Int;
	var severity:String;
	var message:String;
};

typedef FileReport = {
	var fileName:String;
	var messages:Array<ReportMessage>;
};

typedef GlobalReport = Array<FileReport>;