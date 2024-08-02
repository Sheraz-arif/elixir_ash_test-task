defmodule DataDrivenMicroscopy.Repo.Migrations.MigrateResources1 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:systems, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
      add :operating_system, :text
      add :manufacturer, :text
    end

    create table(:pixelsizes, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :value, :float
      add :update_at, :utc_datetime, default: fragment("now()")
      add :objective_id, :uuid
    end

    create table(:objectives, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
    end

    alter table(:pixelsizes) do
      modify :objective_id,
             references(:objectives,
               column: :id,
               prefix: "public",
               name: "pixelsizes_objective_id_fkey",
               type: :uuid
             )
    end

    alter table(:objectives) do
      add :name, :text, null: false
      add :magnification, :bigint, null: false
      add :numerical_aperture, :float
      add :working_distance_min, :float
      add :working_distance_max, :float
      add :immersion_media, :text
      add :objective_type, :text

      add :system_id,
          references(:systems,
            column: :id,
            name: "objectives_system_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create table(:experiments, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text
      add :description, :map
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end

    create table(:cameras, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false

      add :system_id,
          references(:systems,
            column: :id,
            name: "cameras_system_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create table(:camera_calibrations, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :updated_at, :utc_datetime, default: fragment("now()")
      add :a11, :float, null: false
      add :a12, :float, null: false
      add :a21, :float, null: false
      add :a22, :float, null: false

      add :camera_id,
          references(:cameras,
            column: :id,
            name: "camera_calibrations_camera_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:camera_calibrations, "camera_calibrations_camera_id_fkey")

    drop table(:camera_calibrations)

    drop constraint(:cameras, "cameras_system_id_fkey")

    drop table(:cameras)

    drop table(:experiments)

    drop constraint(:objectives, "objectives_system_id_fkey")

    alter table(:objectives) do
      remove :system_id
      remove :objective_type
      remove :immersion_media
      remove :working_distance_max
      remove :working_distance_min
      remove :numerical_aperture
      remove :magnification
      remove :name
    end

    drop constraint(:pixelsizes, "pixelsizes_objective_id_fkey")

    alter table(:pixelsizes) do
      modify :objective_id, :uuid
    end

    drop table(:objectives)

    drop table(:pixelsizes)

    drop table(:systems)
  end
end