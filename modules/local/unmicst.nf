process UNMICST {
    tag "$meta.id"
    label 'process_low'

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit 1, "UnMICST module does not support Conda. Please use Docker / Singularity instead."
    }

    container "docker.io/labsyspharm/unmicst"

    input:
    tuple val(meta), path(images)

    output:
    path("${params.outdir}")
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = ""

    """
    python /app/UnMicst.py \\
    $args \\
    ${images} \\
    --outputPath ${params.outdir}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        UnMICST:: ${VERSION}
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p ${output_path}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        UnMICST:: ${VERSION}
    END_VERSIONS
    """
}
