package checkstyle.reporter;

import checkstyle.LintMessage.SeverityLevel;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class BaseReporter implements IReporter {

	var errors:Int;
	var warnings:Int;
	var infos:Int;
	var total:Int;

	var report:StringBuf;
	var file:FileOutput;

	public function new(path:String) {
		if (path != null) {
			var folder = Path.directory(path);
			if (folder.length > 0 && !FileSystem.exists(folder)) FileSystem.createDirectory(folder);
			file = File.write(path);
			report = new StringBuf();
		}
	}

	public function start() {
		errors = 0;
		warnings = 0;
		infos = 0;
		total = 0;
		Sys.println("");
		Sys.println(styleText("Running Checkstyle...", Style.BOLD));
		Sys.println("");
	}

	public function finish() {
		if (file != null) {
			file.writeString(report.toString());
			file.close();
		}

		total = errors + warnings + infos;

		if (total > 0) {
			Sys.println(
				styleText("\nTotal Issues: " + total + " (", Style.BOLD) +
				styleText("Errors: " + errors, Style.RED) +
				styleText(", ", Style.BOLD) +
				styleText("Warnings: " + warnings, Style.MAGENTA) +
				styleText(", ", Style.BOLD) +
				styleText("Infos: " + infos, Style.BLUE) +
				styleText(")", Style.BOLD));
		}
		else Sys.println(styleText("No issues found.", Style.BOLD));
	}

	public function fileStart(f:LintFile) {}

	public function fileFinish(f:LintFile) {}

	public function addMessage(m:LintMessage) {}

	function styleText(s:String, style:Style):String {
		if (Sys.systemName() == "Windows") return s;
		return '\033[${style}m${s}\033[0m';
	}

	function applyColour(msg:String, s:SeverityLevel):String {
		return switch (s) {
			case ERROR: styleText(msg, Style.RED);
			case WARNING: styleText(msg, Style.MAGENTA);
			case INFO: styleText(msg, Style.BLUE);
			case IGNORE: styleText(msg, Style.BLUE);
		}
	}

	function getMessage(m:LintMessage):StringBuf {
		var sb:StringBuf = new StringBuf();
		sb.add(m.fileName);
		sb.add(':');
		sb.add(m.line);
		if (m.startColumn >= 0) {
			var isRange = m.startColumn != m.endColumn;
			sb.add(': character${isRange ? "s" : ""} ');
			sb.add(m.startColumn);
			if (isRange) {
				sb.add('-');
				sb.add(m.endColumn);
			}
			sb.add(' ');
		}
		sb.add(": ");
		sb.add(BaseReporter.severityString(m.severity));
		sb.add(": ");
		sb.add(m.message);
		sb.add("\n");

		return sb;
	}

	static function severityString(s:SeverityLevel):String {
		return switch (s){
			case INFO: return "Info";
			case WARNING: return "Warning";
			case ERROR: return "Error";
			case IGNORE: return "Ignore";
		}
	}
}

@:enum
@SuppressWarnings("checkstyle:MemberName")
abstract Style(Int) {
	var BOLD = 1;
	var RED = 91;
	var BLUE = 94;
	var MAGENTA = 95;
}