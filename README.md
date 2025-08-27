# Unconscious Elevated Bottom-Up Processing in Depression: Insights from Dynamic Causal Modeling with EEG and fMRI

[![DOI](https://img.shields.io/badge/DOI-10.23668/psycharchives.16417-blue)](https://doi.org/10.23668/psycharchives.16417)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC--BY--4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![Status: Preprint](https://img.shields.io/badge/Status-Preprint-orange.svg)](https://doi.org/10.23668/psycharchives.16417)

---
 
Authors: *Julia Schräder<sup>1,2</sup>, Thilo Kellermann<sup>1,2</sup>, Damin Kühn<sup>³</sup>, Lennard Rompelberg<sup>³</sup>, Michael T. Schaub<sup>³</sup>, Lisa Wagels<sup>1,2</sup>*  

* <sub><sup>1 Department of Psychiatry, Psychotherapy and Psychosomatics, Faculty of Medicine, RWTH Aachen, Aachen, Germany  
* <sub><sup>2 JARA-Translational Brain Medicine, Aachen, Germany  
* <sub><sup>3 Department of Computer Science, RWTH Aachen University, Germany


Published as a preprint in *PsychArchives* (2025).  
DOI: [10.23668/psycharchives.16417](https://doi.org/10.23668/psycharchives.16417)

---

## ✨ Abstract

**Introduction:** MRI compatible EEG systems enable simultaneous EEG-fMRI data assessment, which provides high spatial and high temporal resolution of neural signaling data. Functional connectivity analyses suggest altered fronto-limbic emotion regulation in patients with major depressive disorder (MDD). 

**Methods:** Sixty patients with MDD and 66 healthy controls (HC) performed a priming task using unconsciously and consciously presented emotional facial expressions (happy, sad, neutral) performed a priming task using unconsciously and consciously presented emotional facial expressions. Effective connectivity of simultaneously recorded EEG-fMRI data between cortical (bilateral dorsolateral prefrontal cortex and fusiform gyrus) and subcortical regions (bilateral amygdala) was captured using dynamic causal modeling (DCM). Delineate stimulus-related changes in bottom-up and top-down neurophysiological networks across both EEG and fMRI data were estimated in models of unconscious and conscious processing, defined for both groups.

**Results:** Bayesian model selection favored a bottom-up processing model for both groups and input conditions (conscious and unconscious) in EEG-DCMs. Mixed top-down and bottom-up processing models best represented conscious and unconscious stimulus processing in HC fMRI-DCM, while bottom-up models were most representative for MDD fMRI data. Amygdala activity leads to higher DLPFC activity in conscious, and lower DLPFC activity in unconscious conditions in both groups. 

**Conclusion:** This study demonstrates the distinct capabilities of EEG and fMRI data through showing that EEG captures early and fast processing (bottom-up) while fMRI reflects both, bottom-up and top-down regulation. Activity reduction of DLPFC through FFA bottom-up connectivity in early processing (EEG-DCM) might inhibit later top-down emotion regulation through the DLPFC in MDD (fMRI-DCM).

---

## 📂 Repository Structure

- `results/` – example datasets and results
- `scripts/` – analysis code for EEG, fMRI, and DCM models  

---

## 📑 Citation

If you use or reference this repository, please cite the preprint:

```bibtex
@article{Schraeder2025UnconsciousDCM,
  title   = {Unconscious Elevated Bottom-Up Processing in Depression: Insights from Dynamic Causal Modeling with EEG and fMRI},
  author  = {Schräder, Julia and Kellermann, Thilo and Kühn, Damin and Rompelberg, Lennard and Schaub, Michael T. and Wagels, Lisa},
  year    = {2025},
  journal = {PsychArchives},
  doi     = {10.23668/psycharchives.16417}
}

