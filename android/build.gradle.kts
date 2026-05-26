import org.gradle.api.tasks.compile.JavaCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
        }
    }
}

val newBuildDir = File(rootProject.projectDir, "../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = File(newBuildDir, project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension>("androidComponents") {
            beforeVariants(selector().all()) { variantBuilder ->
                // Keeping this empty as it was in your original setup
            }
        }
        
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            // Safe early override for well-behaved plugins (like file_picker)
            compileSdk = 35
            
            if (namespace == null) {
                val safeProjectName = project.name.replace(Regex("[^A-Za-z0-9_]"), "_")
                namespace = "dev.mtrack.generated.$safeProjectName"
            }
        }
    }

    // THE SURGICAL FIX: Only target Isar specifically. Leaves file_picker completely untouched.
    if (project.name == "isar_flutter_libs") {
        project.afterEvaluate {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdk = 35
            }
        }
    }

    // Some plugin tasks still inject -source/-target 8; force Java 17 at task level.
    tasks.withType(JavaCompile::class.java).configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
        options.compilerArgs.addAll(listOf("-Xlint:-options"))
    }
}