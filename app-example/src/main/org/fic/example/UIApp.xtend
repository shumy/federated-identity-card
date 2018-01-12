package org.fic.example

import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.layout.FlowPane
import javafx.stage.Stage
import org.fic.example.broker.InMemoryBroker
import org.fic.example.broker.InMemoryGateway
import org.fic.example.node.FIApplication
import org.fic.example.node.FICard
import org.fic.example.node.FIGateway
import org.fic.example.node.FITrustedLink

class UIApp extends Application {
  override start(Stage stage) throws Exception {
    val gateway = new InMemoryGateway
    val broker = new InMemoryBroker(gateway)
    
    //broker.logTo[ println('''MSG: «it»''') ]
    
    //FICP nodes...
    val fiGateway = new FIGateway(broker)
    val fiApp = new FIApplication(broker)
    
    val fitl_1 = new FITrustedLink(broker)
    val fitl_2 = new FITrustedLink(broker)
    
    val fiCard = new FICard(broker, fitl_1.card.block.key, fitl_2.card.block.key)
    
    val root = new FlowPane => [
      style = "-fx-background-color: DAE6F3;"
      
      children.add(new TabPane => [
        prefWidth = 1200
        
        tabs.add(new Tab => [
          text = "FI-Card"
          closable = false
          content = fiCard.content
        ])
        
        tabs.add(new Tab => [
          text = "FI-Application"
          closable = false
          content = fiApp.content
        ])
        
        tabs.add(new Tab => [
          text = "FI-TL-1"
          closable = false
          content = fitl_1.content
        ])
        
        tabs.add(new Tab => [
          text = "FI-TL-2"
          closable = false
          content = fitl_2.content
        ])
        
        tabs.add(new Tab => [
          text = "FI-Gateway"
          closable = false
          content = fiGateway.content
        ])
      ])
    ]
    
    //setup stage...
    stage => [
      title = "FICP proof of concept application."
      scene = new Scene(root, 1200, 700)
      show
    ]
  }
}