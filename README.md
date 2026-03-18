# WorkoutTracker Experiment README

## 1. Overview
**WorkoutTracker - Experiment** is the experimental version of the WorkoutTracker iOS application. This version includes benchmarking code used to evaluate the app's performance under different dataset sizes.

The purpose of the experiment is to measure how the application performs as the number of stored workout entries increases. The results are displayed in the **Xcode console output** when the app is run in the simulator.

This experimental version is separate from the main WorkoutTracker application and is intended specifically for performance testing and reproducibility.

---

## 2. Purpose of the Experiment
The experiment was designed to evaluate how well WorkoutTracker scales as more workout data is added.

The benchmark measures how the app behaves with increasing amounts of workout entries and helps answer questions such as:
- How fast does the app load larger datasets?
- How efficiently does it process workout data?
- Does performance remain usable as the number of entries increases?

The experiment validates the app's ability to support long-term use with growing workout history.

---

## 3. Requirements
To reproduce and run this experiment, you need:
- A Mac computer
- Xcode
- iOS Simulator
- The **WorkoutTracker - Experiment** project files

The experiment is run entirely through Xcode.

---

## 4. Project Setup
1. Download or clone the **WorkoutTracker - Experiment** repository.
2. Open the project in Xcode.
3. Make sure the correct simulator is selected.
4. Build and run the app.

Example:
```bash
git clone https://github.com/yourusername/WorkoutTrackerExperiment.git
cd WorkoutTrackerExperiment
open WorkoutTracker.xcodeproj
``` 

---

## 5. How to Run the Experiment
The experiment is reproduced by launching the app in the iOS Simulator through Xcode.

### Steps
1. Open **WorkoutTracker - Experiment** in Xcode.
2. Select an iPhone simulator.
3. Press the **Run** button.
4. Wait for the app to launch in the simulator.
5. View the benchmark results in the Xcode console.

The benchmark output is printed directly to the console when the experiment code runs.

---

## 6. Where to View the Results
The experimental results do not appear as part of the app's visual interface. Instead, they are shown in the **Xcode debug console / command-line output** area.

To see the results:
1. Run the app in Xcode.
2. Open the console area at the bottom of the Xcode window.
3. Read the benchmark output printed there.

The console displays the performance results for each dataset size tested.

---

## 7. Experimental Method
The benchmark tests the application using synthetic workout datasets of different sizes.

Example dataset sizes include:
- 100 entries
- 1,000 entries
- 10,000 entries

For each dataset size, the experiment generates sample workout data and measures app performance. The results are printed in the console.

The purpose is to compare how performance changes as the amount of stored data grows.

---

## 8. Metrics Collected
The experiment evaluates performance using benchmark output shown in the Xcode console.

The results may include measurements such as:
- Load time
- Data generation time
- Processing time
- Analytics computation time
- Overall performance across dataset sizes

These measurements are used to assess the scalability and responsiveness of the application.

---

## 9. Reproducing the Results
To reproduce the experiment consistently:
1. Use the same version of the **WorkoutTracker - Experiment** project.
2. Run the project in Xcode using the iOS Simulator.
3. Keep the simulator/device choice consistent between runs.
4. Observe the benchmark results printed in the Xcode console.
5. Repeat the process if multiple trials are needed.

If the benchmark is configured to average multiple runs, allow the full benchmark process to complete before recording results.

---

## 10. Example Reproduction Workflow
A viewer can reproduce the experiment using the following workflow:
1. Open the project in Xcode.
2. Select an iPhone simulator.
3. Run the application.
4. Wait for the benchmark to execute automatically.
5. Read the dataset benchmark results in the console.
6. Compare the reported timings across dataset sizes.

This provides a direct way for instructors, reviewers, or other developers to verify the experiment.

---

## 11. Expected Output
When the experiment runs successfully, the console should display benchmark information for multiple dataset sizes.

The output should show that:
- Small datasets complete quickly
- Larger datasets take more processing time
- Performance trends can be compared across runs

The exact times may vary depending on the machine and simulator, but the general trend should remain consistent.

---

## 12. Notes on Reproducibility
Some variation in output may occur depending on:
- Mac hardware
- Xcode version
- Simulator model
- Background system activity

Because of this, reproduced benchmark values may not be exactly identical on every machine. However, the overall pattern of increasing cost with larger datasets should still be observable.

---

## 13. Threats to Validity
The following factors may affect the experiment:
- Synthetic workout data may not perfectly match real-world usage
- Simulator performance may differ from a physical iPhone
- Background processes may affect timing measurements
- Different hardware may produce different timing results

These limitations should be considered when interpreting the benchmark results.

---

## 14. Technologies Used
- Swift
- SwiftUI
- Xcode
- iOS Simulator
- iOS SDK

---

## 15. Author
**Evan Nelson** — Senior Capstone Project
```
