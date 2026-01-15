- Kind: Narrative
  Name: SystemPurpose
  Content:
    - The system under test is a Java web application that has been migrated from an Apache Struts MVC framework to a Spring Boot RESTful architecture.
    - Its goal is to expose HTTP endpoints that return JSON payloads, use Spring Data JPA for persistence, and be buildable and runnable via Maven.

- Kind: Model
  Name: Codebase
  Fields:
    - src: directory — source files of the Java project.
    - pom.xml: file — Maven project descriptor.
    - application.yml / application.properties: file (optional) — Spring Boot configuration.
    - hidden-test-dir: directory (optional) — contains hidden golden JSON files used by runtime verification.

- Kind: Model
  Name: SpringEntity
  Fields:
    - className: string — name of a Java class annotated with @Entity.
    - fields: array of object — each object represents a persistent property (type and name unknown from static tests).

- Kind: Operation
  Name: ValidateNoStrutsImports
  Description: Ensure the source tree does not import any Struts classes.
  Behaviors:
    - Passes when no line in any source file contains `import org.apache.struts` .
    - Fails when such an import is found.

- Kind: Operation
  Name: ValidateNoActionClasses
  Description: Ensure no class extends the Struts `Action` base class.
  Behaviors:
    - Passes when no source file contains `extends Action`.
    - Fails when such a class is detected.

- Kind: Operation
  Name: ValidateNoActionFormClasses
  Description: Ensure no class extends the Struts `ActionForm` base class.
  Behaviors:
    - Passes when no source file contains `extends ActionForm`.
    - Fails when such a class is detected.

- Kind: Operation
  Name: ValidateNoActionMappingOrForwardUsage
  Description: Ensure the code does not reference Struts `ActionMapping` or `ActionForward` types (except inside comments that contain the word “Action”).
  Behaviors:
    - Passes when a grep for `ActionMapping|ActionForward` finds no matches outside comments.
    - Fails when such a usage is found.

- Kind: Operation
  Name: ValidateNoStrutsConfigFile
  Description: Ensure the traditional Struts configuration file `struts-config.xml` is absent.
  Behaviors:
    - Passes when the file cannot be found under the project root.
    - Fails when the file exists.

- Kind: Operation
  Name: ValidateNoJspFiles
  Description: Ensure the project does not contain any JSP view files.
  Behaviors:
    - Passes when no file with extension `.jsp` exists.
    - Fails when at least one JSP file is present.

- Kind: Operation
  Name: ValidateNoManualJsonConstruction
  Description: Ensure JSON payloads are not built manually with `org.json` classes or custom helpers.
  Behaviors:
    - Passes when no import or reference to `org.json`, `JSONObject`, or `JsonHelper` appears outside commented code.
    - Fails when such references are found.

- Kind: Operation
  Name: WarnSingletonPatternUsage
  Description: Detect potential legacy Singleton DAO usage.
  Behaviors:
    - Emits a warning (not a failure) when any source file contains a call to `getInstance()` outside a comment.
    - No warning is emitted when the pattern is absent.

- Kind: Operation
  Name: ValidateSpringBootApplicationAnnotation
  Description: Verify that a class is annotated with `@SpringBootApplication`.
  Behaviors:
    - Passes when at least one source file contains `@SpringBootApplication`.
    - Fails when none is found.

- Kind: Operation
  Name: ValidateRestControllerAnnotation
  Description: Verify that at least one class is annotated with `@RestController`.
  Behaviors:
    - Passes when a `@RestController` annotation is present in the source tree.
    - Fails when it is missing.

- Kind: Operation
  Name: ValidateHttpMethodMappings
  Description: Verify that the code uses Spring MVC request‑mapping annotations.
  Behaviors:
    - Passes when any of `@GetMapping`, `@PostMapping`, `@PutMapping`, or `@DeleteMapping` appear.
    - Fails when none are found.

- Kind: Operation
  Name: ValidateJpaRepositoryImplementation
  Description: Ensure a Spring Data repository interface is present.
  Behaviors:
    - Passes when a source file contains `extends JpaRepository` or `extends CrudRepository`.
    - Fails when no such interface is detected.

- Kind: Operation
  Name: ValidateEntityAnnotationPresence
  Description: Detect at least one JPA entity class.
  Behaviors:
    - Passes (with a warning) when an `@Entity` annotation is found.
    - Emits a warning (not a failure) when none is found, allowing in‑memory storage alternatives.

- Kind: Operation
  Name: ValidateSpringRequestParameterAnnotations
  Description: Ensure controller methods use Spring’s request‑binding annotations.
  Behaviors:
    - Passes when any of `@PathVariable`, `@RequestParam`, or `@RequestBody` appear in source files.
    - Fails when none are present.

- Kind: Operation
  Name: ValidateSpringBootConfigurationFile
  Description: Check for a Spring Boot configuration file.
  Behaviors:
    - Passes (with a warning) when either `application.yml` or `application.properties` exists.
    - Emits a warning when neither is found.

- Kind: Operation
  Name: ValidateSpringBootParentInPom
  Description: Verify that the Maven POM uses the Spring Boot starter parent.
  Behaviors:
    - Passes when `spring-boot-starter-parent` appears in `pom.xml`.
    - Fails when the parent is missing.

- Kind: Operation
  Name: MavenBuildSuccess
  Description: Run `mvn clean package -DskipTests` and confirm it exits with status 0.
  Behaviors:
    - Passes when the Maven command completes successfully.
    - Fails when the command returns a non‑zero exit code or `pom.xml` is absent.

- Kind: Operation
  Name: HiddenGoldenFileDetection
  Description: Detect the presence of hidden golden JSON files used for runtime verification.
  Behaviors:
    - Emits a warning indicating the number of hidden test cases when the hidden directory exists (actual runtime validation is performed later).
    - Passes silently when the hidden directory does not exist.

- Kind: Invariant
  Name: NoStrutsArtifactsInvariant
  Statements:
    - The codebase must contain zero occurrences of Struts imports, classes extending `Action` or `ActionForm`, usages of `ActionMapping`/`ActionForward`, a `struts-config.xml` file, or any `.jsp` view files.
    - Violation of any part results in a test failure.

- Kind: Invariant
  Name: SpringBootArtifactsInvariant
  Statements:
    - The codebase must contain at least one `@SpringBootApplication` class, at least one `@RestController`, at least one HTTP method mapping annotation, and a Maven POM that declares `spring-boot-starter-parent`.
    - Failure to meet any required element causes a test failure; missing optional elements (e.g., `@Entity`, configuration file) generate warnings but do not fail the static suite.

- Kind: Invariant
  Name: BuildabilityInvariant
  Statements:
    - A Maven build (`mvn clean package -DskipTests`) must complete without error.
    - If the build fails, the overall static test suite fails.

- Kind: EdgeCase
  Name: MissingPomXml
  Scenarios:
    - `pom.xml` does not exist → immediate failure of Maven‑related checks and the overall suite.
    - Presence of `pom.xml` without the Spring Boot parent → of the “SpringBootParentInPom” operation.

- Kind: EdgeCase
  Name: AbsentSpringBootAnnotations
  Scenarios:
    - No class annotated with `@SpringBootApplication` → failure of the corresponding validation.
    - No class annotated with `@RestController` → failure of the corresponding validation.
    - No HTTP method mapping annotations → failure of the corresponding validation.

- Kind: EdgeCase
  Name: OptionalEntityOrConfigMissing
  Scenarios:
    - No `@Entity` annotation found → a warning is issued but the static suite still passes.
    - No `application.yml` or `application.properties` found → a warning is issued but the suite still passes.

- Kind: EdgeCase
  Name: HiddenRuntimeTestsNotExecuted
  Scenarios:
    - Hidden golden JSON files exist → the script only counts them and emits a warning; actual endpoint behavior, status‑code handling, and JSON correctness are verified later at runtime.
    - No hidden directory → a note is printed; no impact on static test outcome.

- Kind: Unknown
  Name: RuntimeApiBehavior
  Notes:
    - The actual HTTP endpoints, request/response schemas, business logic, and error‑handling semantics are not exercised by the static tests.
    - It is unknown which URLs exist, what JSON structures are returned, or how validation errors are reported.

- Kind: Unknown
  Name: DataModelDetails
  Notes:
    - Apart from the existence of at least one `@Entity`, the fields, relationships, and validation constraints of domain entities are unspecified.
    - The persistence store (relational DB, in‑memory, etc.) is not determined.

- Kind: Unknown
  Name: SingletonPatternImpact
  Notes:
    - The script only warns about `getInstance()` calls; it does not verify whether a Singleton pattern is still used or whether it has been correctly refactored.
    - The functional impact of any remaining Singleton DAO is unknown.

- Kind: Unknown
  Name: ManualJsonConstructionScope
  Notes:
    - The test forbids imports of `org.json` and usage of `JSONObject`/`JsonHelper`, but it does not inspect whether other manual JSON building techniques (e.g., string concatenation) are employed. The presence or absence of such techniques is unknown.