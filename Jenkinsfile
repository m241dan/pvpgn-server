pipeline {

   agent any

   stages {
      stage('Build PVPGN') {
         steps {
            sh '''
               docker build --target production -t pvpgn:1.0 .
            '''
         }
      }
   }
}
