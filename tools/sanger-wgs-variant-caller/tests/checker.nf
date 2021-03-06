#!/usr/bin/env nextflow

/*
 * Copyright (c) 2020, Ontario Institute for Cancer Research (OICR).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

/*
 * author Linda Xiang <linda.xiang@oicr.on.ca>
 */

nextflow.preview.dsl=2

params.ref_genome_tar = ""
params.vagrent_annot = ""
params.ref_snv_indel_tar = ""
params.ref_cnv_sv_tar = ""
params.qcset_tar = ""
params.tumour = ""
params.tumourIdx = ""
params.normal = ""
params.normalIdx = ""

include { sangerWgsVariantCaller; getSangerWgsSecondaryFiles } from '../sanger-wgs-variant-caller' params(params)

Channel
  .fromPath(getSangerWgsSecondaryFiles(params.tumour), checkIfExists: true)
  .set { tumour_ch }

Channel
  .fromPath(getSangerWgsSecondaryFiles(params.normal), checkIfExists: true)
  .set { normal_ch }

// will not run when import as module
workflow {
  main:
    sangerWgsVariantCaller(
      file(params.ref_genome_tar),
      file(params.vagrent_annot),
      file(params.ref_snv_indel_tar),
      file(params.ref_cnv_sv_tar),
      file(params.qcset_tar),
      file(params.tumour),
      file(params.tumourIdx),
      tumour_ch.collect(),
      file(params.normal),
      file(params.normalIdx),
      normal_ch.collect()
    )

  publish:
    sangerWgsVariantCaller.out to: "outdir", overwrite: true
}
