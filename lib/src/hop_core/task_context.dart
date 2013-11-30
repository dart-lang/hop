part of hop.core;

/**
 * The context of a [Task] invoked by the user.
 *
 * Contains the parsed [ArgResults] parsed from the user.
 */
abstract class TaskContext implements TaskLogger {

  ArgResults get arguments;

  /**
   * **DEPRECATED** Use [getSubLogger] instead.
   */
  @deprecated
  TaskContext getSubContext(String name);

  /**
   * Terminates the current [Task] with a failure, explained by [message].
   */
  void fail(String message) {
    throw new TaskFailError(message);
  }
}
