local pipeline = import 'spin-lib-jsonnet/pipeline.libsonnet';
local stage = import 'spin-lib-jsonnet/stage.libsonnet';
local kube = import 'spin-lib-jsonnet/kube.libsonnet';
local parameter = import 'spin-lib-jsonnet/parameter.libsonnet';
local spel = import 'spin-lib-jsonnet/spel.libsonnet';

function(params={}) (
	pipeline.Pipeline {
		application: params["application"],
		name: params["pipeline"],
    keepWaitingPipelines: true,
    limitConcurrent: false,
    parameterConfig: [
      parameter.Parameter {
        name: 'echo1',
      },
    ],
		Stages:: [
			stage.RunKubeJobStage {
				name: 'Run My Kube Job 1',
        application: $.application,
				account: 'k8s',
				credentials: 'k8s',
				manifest: kube.Manifest {
          generateName:: "shoredemo",
          containers:: [{
            name: "test1",
            image: "busybox",
            command: [
              "echo",
              spel.expression(spel.parameter('echo1')),
              // spel.expression('%s.toString()' % spel.parameter('echo1')),
            ],
          }]
				},
			},
      stage.NestedPipelineStage {
        name: 'nested',
        Parent:: $,
        Pipeline:: pipeline.Pipeline {
          application: params["application"],
          name: "nested-%s" % [$.name],
          keepWaitingPipelines: true,
          limitConcurrent: false,
          Stages:: [
            stage.RunKubeJobStage {
              name: 'Run My Kube Job 1',
              application: $.application,
              account: 'k8s',
              credentials: 'k8s',
              manifest: kube.Manifest {
                generateName:: "shoredemo",
                containers:: [{
                  name: "test1",
                  image: "busybox",
                  command: [
                    "echo",
                    spel.expression(spel.parameter('echo1')),
                  ],
                }]
              },
            }
          ]
        }
      }
		]
	}
)
