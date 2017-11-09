package org.fic

import com.fasterxml.jackson.annotation.JsonInclude.Include
import com.fasterxml.jackson.databind.ObjectMapper
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import java.time.temporal.Temporal
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

class JsonDynamicProfile {
  static val defaultProfile = new Profile => [
    mapper = new ObjectMapper => [
      serializationInclusion = Include.NON_EMPTY
    ]
    
    formatters = #{
      LocalDate -> DateTimeFormatter.ISO_LOCAL_DATE,
      LocalTime -> DateTimeFormatter.ISO_LOCAL_TIME,
      LocalDateTime -> DateTimeFormatter.ISO_LOCAL_DATE_TIME
    }
  ]
  
  static val profile = new ThreadLocal<Profile> {
    override protected initialValue() { defaultProfile }
  }
  
  static def String serialize(Object obj) {
    profile.get.mapper.writeValueAsString(obj)
  }
  
  static def <T> T deserialize(Class<T> clazz, String json) {
    profile.get.mapper.readValue(json, clazz)
  }
  
  static def getFormater(Class<? extends Temporal> clazz) {
    profile.get.formatters.get(clazz)
  }
  
  @Accessors
  static class Profile {
    ObjectMapper mapper
    Map<Class<?>, DateTimeFormatter> formatters
  }
}