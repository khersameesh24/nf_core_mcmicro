process S3SEGMENTER {
    tag "$meta.id"
    label 'process_low'

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit 1, "s3Segmeter module does not support Conda. Please use Docker / Singularity instead."
    }

    container "docker.io/koetjen/mcmicro:090822"

    input:
    tuple val(meta), path(image)
    path(stack_prob_path)

    output:
    path("${params.outdir}")
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = ""

    """
    python /app/S3segmenter.py \\
    ${args} \\
    --imagePath ${image} \
    --stackProbPath ${stack_prob_path} \
    --outputPath ${params.outdir}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        s3segmenter:: ${VERSION}
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${output_path}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        s3segmenter:: ${VERSION}
    END_VERSIONS
    """
}
