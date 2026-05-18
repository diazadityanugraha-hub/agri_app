allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = "com.example." + project.name.replace("-", ".")
            }
        }
    }

    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (requested.group == "org.jetbrains.kotlin") {
                    useVersion("1.9.22")
                }
            }
        }
    }
}

rootProject.buildDir = layout.buildDirectory.dir("../../build").get().asFile
subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}