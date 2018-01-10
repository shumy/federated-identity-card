package org.fic.example

import picocli.CommandLine.Command
import picocli.CommandLine.Option
import picocli.CommandLine
import javafx.application.Application

@Command(
  name = "fic-example", footer = "Copyright(c) 2017",
  description = "FICP proof of concept application."
)
class RCommand {
  @Option(names = #["-h", "--help"], help = true, description = "Display this help and exit.")
  public boolean help
  
  @Option(names = #["--stack"], help = true, description = "Display the stack trace error if any.")
  public boolean stack
}

class FicExample {
  def static void main(String[] args) {
    val cmd =  try {
      CommandLine.populateCommand(new RCommand, args)
    } catch (Throwable ex) {
      CommandLine.usage(new RCommand, System.out)
      return
    }
    
    try {
      if (cmd.help) {
        CommandLine.usage(new RCommand, System.out)
        return
      }
      
      //run UI application by default
      println("Searching JavaFX at: " + System.getProperty("java.home"))
      Application.launch(UIApp, args)
      
    } catch (Throwable ex) {
      if (cmd.stack)
        ex.printStackTrace
      else
        println(ex.message)
    }
  }
}