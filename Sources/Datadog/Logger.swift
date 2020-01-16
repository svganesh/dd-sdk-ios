import Foundation

/// Log levels ordered by their severity, with `.debug` being the least severe and
/// `.critical` being the most severe.
public enum LogLevel: Int, Codable {
    case debug
    case info
    case notice
    case warn
    case error
    case critical
}

public class Logger {
    /// Writes `Log` objects to output.
    let logOutput: LogOutput

    init(logOutput: LogOutput) {
        self.logOutput = logOutput
    }

    /// Sends a DEBUG log message.
    /// - Parameter message: the message to be logged
    public func debug(_ message: @autoclosure () -> String) {
        log(level: .debug, message: message())
    }

    /// Sends an INFO log message.
    /// - Parameter message: the message to be logged
    public func info(_ message: @autoclosure () -> String) {
        log(level: .info, message: message())
    }

    /// Sends a NOTICE log message.
    /// - Parameter message: the message to be logged
    public func notice(_ message: @autoclosure () -> String) {
        log(level: .notice, message: message())
    }

    /// Sends a WARN log message.
    /// - Parameter message: the message to be logged
    public func warn(_ message: @autoclosure () -> String) {
        log(level: .warn, message: message())
    }

    /// Sends an ERROR log message.
    /// - Parameter message: the message to be logged
    public func error(_ message: @autoclosure () -> String) {
        log(level: .error, message: message())
    }

    /// Sends a CRITICAL log message.
    /// - Parameter message: the message to be logged
    public func critical(_ message: @autoclosure () -> String) {
        log(level: .critical, message: message())
    }

    private func log(level: LogLevel, message: @autoclosure () -> String) {
        logOutput.writeLogWith(level: level, message: message())
    }

    // MARK: - Logger.Builder

    public static var builder: Builder {
        return Builder()
    }

    public class Builder {
        private var serviceName: String = "ios"
        private var useFileOutput = true
        private var useConsoleLogFormat: ConsoleLogFormat?

        /// Sets the service name that will appear in logs.
        /// - Parameter serviceName: the service name (default value is "ios")
        public func set(serviceName: String) -> Builder {
            self.serviceName = serviceName
            return self
        }

        /// Enables logs to be sent to Datadog servers.
        /// Can be used to disable sending logs in development.
        /// See also: `printLogsToConsole(_:)`.
        /// - Parameter enabled: `true` by default
        public func sendLogsToDatadog(_ enabled: Bool) -> Builder {
            self.useFileOutput = enabled
            return self
        }

        /// Format to use when printing logs to console if `printLogsToConsole(_:)` is enabled.
        public enum ConsoleLogFormat {
            /// Prints short representation of log.
            case short
            /// Prints short representation of log with given prefix.
            case shortWith(prefix: String)
            /// Prints JSON representation of log.
            case json
            /// Prints JSON representation of log with given prefix.
            case jsonWith(prefix: String)
        }

        /// Enables  logs to be printed to debugger console.
        /// Can be used in development instead of sending logs to Datadog servers.
        /// See also: `sendLogsToDatadog(_:)`.
        /// - Parameters:
        ///   - enabled: `false` by default
        ///   - format: format to use when printing logs to console - either `.short` or `.json` (`.short` is default)
        public func printLogsToConsole(_ enabled: Bool, usingFormat format: ConsoleLogFormat = .short) -> Builder {
            useConsoleLogFormat = enabled ? format : nil
            return self
        }

        public func build() -> Logger {
            do { return try buildOrThrow()
            } catch {
                userLogger.critical("\(error)")
                fatalError("`Logger` cannot be built: \(error)") // crash
            }
        }

        internal func buildOrThrow() throws -> Logger {
            guard let datadog = Datadog.instance else {
                throw ProgrammerError(description: "`Datadog.initialize()` must be called prior to `Logger.builder.build()`.")
            }

            return Logger(logOutput: resolveLogsOutput(using: datadog))
        }

        private func resolveLogsOutput(using datadog: Datadog) -> LogOutput {
            let logBuilder = LogBuilder(
                serviceName: serviceName,
                dateProvider: datadog.dateProvider
            )

            switch (useFileOutput, useConsoleLogFormat) {
            case (true, let format?):
                return CombinedLogOutput(
                    combine: [
                        LogFileOutput(
                            logBuilder: logBuilder,
                            fileWriter: datadog.logsPersistenceStrategy.writer
                        ),
                        LogConsoleOutput(
                            logBuilder: logBuilder,
                            format: format
                        )
                    ]
                )
            case (true, nil):
                return LogFileOutput(
                    logBuilder: logBuilder,
                    fileWriter: datadog.logsPersistenceStrategy.writer
                )
            case (false, let format?):
                return LogConsoleOutput(
                    logBuilder: logBuilder,
                    format: format
                )
            case (false, nil):
                return NoOpLogOutput()
            }
        }
    }
}