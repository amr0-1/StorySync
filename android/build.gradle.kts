import org.gradle.api.tasks.compile.JavaCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.6.0")
            force("androidx.core:core-ktx:1.6.0")
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
                // Removed because disabling unit tests globally breaks plugins like shared_preferences_android in newer AGP.
                // variantBuilder.enableUnitTest = false
                // variantBuilder.enableAndroidTest = false
            }
        }
        
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            compileSdk = 36
            if (namespace == null) {
                val safeProjectName = project.name.replace(Regex("[^A-Za-z0-9_]"), "_")
                namespace = "dev.mtrack.generated.$safeProjectName"
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
